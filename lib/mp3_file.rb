class Mp3File
  attr_reader :contents, :validation_errors, :info, :file
  attr_accessor :id

  include Mp3FileValidations

  STORE_DIR = 'public/mp3_files'
  V2_TAGNAME_MAPPING = {
    'TIT2' => 'title',
    'TPE1' => 'artist',
    'TALB' => 'album',
    'TYER' => 'year',
    'TCON' => 'genre',
    'TPUB' => 'publisher',
    'COMM' => 'comments'
  }

  # == Initialize Mp3 File object
  def initialize(*args)
    if !args || args.empty?
      raise ArgumentError, "Incorrect arguments specified to build Mp3File.
        Examples: Mp3File.new(file: #<File:...>)"
    else
      @file = args.first[:file]
    end

    validate!
  end

  # == Validate
  def validate!
    @validation_errors = {}

    validate_mime_type('File type', @file, @validation_errors)
  end

  def save
    if valid?
      unless persistent?
        # store new file in project with the link redis link
        prefix = Digest::MD5.hexdigest(Time.now.to_f.to_s).last(4)
        mp3_file_path = File.join(STORE_DIR, prefix + File.basename(@file.path))
        FileUtils.cp(@file.path, mp3_file_path)

        UAWCFinal.application_redis.set(self.assign_new_id, mp3_file_path)

        File.join(STORE_DIR, prefix + File.basename(@file.path))
      end

      true
    else
      false
    end
  end

  def update_tags(tag_hash)
    Mp3Info.open(@file.path) do |mp3|
      mp3.tag1 = tag_hash['v1']

      # next line raises error in library, doing manually
      # mp3.tag2 = tag_hash['v2']
      mp3.tag2.TIT2 = tag_hash['v2']['TIT2']
      mp3.tag2.TPE1 = tag_hash['v2']['TPE1']
      mp3.tag2.TALB = tag_hash['v2']['TALB']
      mp3.tag2.TYER = tag_hash['v2']['TYER']
      mp3.tag2.TCON = tag_hash['v2']['TCON']
      mp3.tag2.TPUB = tag_hash['v2']['TPUB']
      mp3.tag2.COMM = tag_hash['v2']['COMM']
    end
  end

  def persistent?
    return false unless @id

    UAWCFinal.application_redis.keys.include?(@id)
  end

  def assign_new_id
    @id = Digest::MD5.hexdigest(Time.now.to_f.to_s).last(8)
  end

  def generate_waveform_image
    WaveformGenerator.new(@file.path).generate_waveform
  end

  def email_file(recipient) #:nodoc:
    smtp_settings = {
      :address              => "smtp.gmail.com",
      :port                 => 587,
      :user_name            => "teachme.notifier@gmail.com",
      :password             => "teachme.notifier",
      :authentication       => "plain",
      :enable_starttls_auto => true
    }

    Mail.defaults do
      delivery_method :smtp, smtp_settings
    end

    path = @file.path

    begin
      Mail.deliver do
        to recipient
        from 'uawc-mp3-editor-tool@uawc-mp3-editor.com'
        subject 'Your mp3 file has successfully been generated'
        body 'Your mp3 file has successfully been generated'
        attachments[File.basename(path)] = File.read(path)
      end
    rescue => exception
    end
  end

  def valid?
    @validation_errors && @validation_errors.empty?
  end

  def info
    @info ||= Mp3Info.open(@file.path) if valid?
  end

  def reload_info!
    @info = Mp3Info.open(@file.path) if valid?
  end

  def error_full_messages #:nodoc:
    @validation_errors.map do |attribute, validation_error|
      "#{attribute.to_s.capitalize} #{validation_error}"
    end
  end

  def self.find(id)
    filepath = UAWCFinal.application_redis.get(id)

    raise Errno::ENOENT.new unless filepath

    mp3_file = self.new(file: File.open(filepath, 'r'))
    mp3_file.id = id
    mp3_file
  end


end