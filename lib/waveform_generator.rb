class WaveformGenerator

  WAVEFORM_IMAGE_PATH = 'public/waveforms'
  IMAGE_PIXEL_WIDTH = 900
  IMAGE_PIXEL_HEIGHT = 300

  def initialize(path)
    @path = path
  end

  def generate_waveform
    peaks = generate_peaks(convert_input_to_wav)
    draw_image(peaks)
  end

  def convert_input_to_wav
    filename = File.basename(@path)
    wav_path = File.join('tmp', Digest::MD5.hexdigest(Time.now.to_f.to_s).last(4) + '.wav')
    system "ffmpeg -i #{@path} -f wav #{wav_path} > /dev/null 2>&1"

    wav_path
  end

  def generate_peaks(wav_path)
    sound_object = RubyAudio::Sound.open(wav_path)
    jump_length  = sound_object.info.frames / IMAGE_PIXEL_WIDTH
    sound_buffer = RubyAudio::Buffer.new('float', jump_length, sound_object.info.channels)

    peaks = []
    while(sound_object.read(sound_buffer) > 0) do
      peaks << sound_buffer.map { |frame| frame.max }.max
    end
    FileUtils.rm(wav_path)
    peaks
  end

  def draw_image(peaks)
    image = Magick::Image.new(IMAGE_PIXEL_WIDTH, IMAGE_PIXEL_HEIGHT) do
      self.background_color = "#ffffff"
    end
    gc = Magick::Draw.new

    peaks.each_with_index do |peak, index|
      gc.stroke('#0011aa')
      gc.stroke_antialias(false)
      gc.stroke_width(1)

      start_x = index
      start_y = (IMAGE_PIXEL_HEIGHT - peak * IMAGE_PIXEL_HEIGHT) / 2
      end_x   = index
      end_y   = start_y + peak * IMAGE_PIXEL_HEIGHT

      gc.line(start_x, start_y, end_x, end_y)
    end

    gc.draw(image)
    output_image = File.join(WAVEFORM_IMAGE_PATH, Digest::MD5.hexdigest(Time.now.to_f.to_s).last(8) + '.png')
    image.write(output_image)

    File.basename(output_image)
  end

end