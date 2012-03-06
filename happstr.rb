class Happstr < Sinatra::Base
  # myapp.rb
  require 'sinatra'


  # connect with mongo/redis somehow

  # serve static content

  get '/' do
    send_file File.join(settings.public_folder, 'html/index.html')
  end


  # api

  get 'api/checkins' do
    # parse parameters
    # fail if no params with it that make sense

    # fetch from storage
    # output json
  end


  post 'api/checkins' do
    # check data coming in if makes sense

    # put into data store
  end

  put 'api/checkins/:id' do
    # validate incoming data

    # update data in store
  end
end
