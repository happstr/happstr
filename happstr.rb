class Happstr < Sinatra::Base
  require 'sinatra'
  require 'mongoid'

  #
  # Configuration
  #
  Mongoid.configure do |config|
    if ENV['MONGOHQ_URL']
      conn = Mongo::Connection.from_uri(ENV['MONGOHQ_URL'])
      uri = URI.parse(ENV['MONGOHQ_URL'])
      config.master = conn.db(uri.path.gsub(/^\//, ''))
    else
      config.master = Mongo::Connection.from_uri("mongodb://localhost:27017").db('test')
    end
  end

  #
  # Models
  #

  class Checkin
    include Mongoid::Document
    include Mongoid::Spacial::Document

    field :created_at, :type => DateTime
    field :source,     :type => Array, :spacial => { return_array: true }

    spacial_index :source
  end

  #
  # Routes
  #
  get '/' do
    send_file File.join(settings.public_folder, 'html/index.html')
  end

  get '/api/checkins' do
    Checkin.where(:source.near => [[30.264924, -97.741413], 10000000]).to_a.to_json

    # parse parameters
    # fail if no params with it that make sense

    # fetch from storage
    # output json
  end


  post '/api/checkins' do
    # check data coming in if makes sense

    # put into data store
  end

  put '/api/checkins/:id' do
    # validate incoming data

    # update data in store
  end

  #
  # Development helpers

  get '/dev/setup' do
    Checkin.create_indexes
    #Checkin.spacial_index 'collect_from.location'

    "done"
  end

  get '/dev/bootstrap' do
    downtown_austin = [30.264924, -97.741413]

    (1..10).each do |lat|
      (1..10).each do |lon|
        unless (lat*lon % 3 == 0)
          Checkin.create(
            created_at: Time.now,
            source:   {:lat => downtown_austin[0] + lat * 0.001, :lng => downtown_austin[1] + lon * 0.001},
            comment:    "Downtown Austin #{lat} #{lon}"
          )
        end
      end
    end

    "done"
  end
end
