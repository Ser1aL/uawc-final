require 'sinatra/base'
require 'sinatra/reloader'
require 'mail'
require 'pry'
require 'open-uri'
require 'haml'
require 'mp3info'
require 'redis'
require 'ruby-audio'
require 'rmagick'

require_relative './lib/waveform_generator'
require_relative './lib/mp3_file_validations'
require_relative './lib/mp3_file'

class UAWCFinal < Sinatra::Base #:nodoc:

  run! if app_file == $0

  configure do #:nodoc:
    register Sinatra::Reloader
    set :server, :puma
    set :haml, { :format => :html5 }
  end

  get '/' do #:nodoc:
    haml :index, layout: :'layouts/application'
  end

  # == Upload file action
  #
  # Users land here when submit their file into the system.
  # The action initiates the file by temporary path and
  # renders the edit tab
  post '/upload_file' do
    mp3_file = Mp3File.new(file: params['mp3_file'][:tempfile])

    unless mp3_file.save
      error_message = mp3_file.error_full_messages.join("\n")
      mp3_file = nil
    end

    haml :index, layout: :'layouts/application', locals: {
      error_message: error_message,
      mp3_file: mp3_file
    }
  end

  # == Submit link action
  #
  # Users come here when submit the remote link.
  # The action initiates remote connection, downloads the file,
  # builds the Mp3 File object and renders the edit tab.
  post '/upload_by_link' do
    file_link = params['mp3_file_link']

    if params['mp3_file_link'] =~ URI.regexp
      begin
        mp3_file = Mp3File.new(file: open(params['mp3_file_link']))

        unless mp3_file.save
          error_message = mp3_file.error_full_messages.join("\n")
          mp3_file = nil
        end
      rescue => any_http_error
        error_message = 'Unable to download the file. Is the link correct?'
      end
    else
      error_message = 'The link specified is not valid'
    end

    haml :index, layout: :'layouts/application', locals: {
      error_message: error_message,
      mp3_file: mp3_file
    }
  end

  # Update tags
  post '/update/:id' do
    mp3_file = Mp3File.find(params[:id])
    mp3_file.update_tags(params['mp3file'])
    mp3_file.reload_info!

    haml :index, layout: :'layouts/application', locals: {
      success_message: "Tags were updated for ##{params[:id]}",
      mp3_file: mp3_file
    }
  end

  get '/generate_waveform/:id' do
    puts "---started generation"
    mp3_file = Mp3File.find(params[:id])
    waveform_png = mp3_file.generate_waveform_image

    content_type :json
    { waveform: waveform_png }.to_json
  end

  # Direct download
  get '/download/:id' do
    mp3_file = Mp3File.find(params[:id])
    send_file mp3_file.file.path, filename: File.basename(mp3_file.file.path), type: 'audio/mpeg'
  end

  # Mailing file
  post '/email/:id' do
    success_message = error_message = nil

    mp3_file = Mp3File.find(params[:id])

    if params[:email] && !params[:email].empty?
      mp3_file.email_file(params[:email])
      success_message = 'The file was emailed successfully'
    else
      error_message = 'Please, fill in the email address'
    end

    haml :index, layout: :'layouts/application', locals: {
      success_message: success_message,
      error_message: error_message,
      mp3_file: mp3_file
    }
  end


  def self.application_redis #:nodoc:
    @redis ||= Redis.new(:host => "127.0.0.1", :port => 6379, :db => 1)
  end

end
