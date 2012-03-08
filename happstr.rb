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
    field :location,   :type => Array, :spacial => { return_array: true }

    spacial_index :source
  end
  Checkin.spacial_index 'collect_from.location'

  #
  # Routes
  #
  get '/' do
    send_file File.join(settings.public_folder, 'html/index.html')
  end

  get '/api/checkins' do

    #checkin_old = Checkin.create(
      #created_at: Time.now,
      #location:   {:lat => 1.106667, :lng => 2.935833},
      #comment:    "Far away checkin"
    #)

    #checkin_main = Checkin.create(
      #created_at: Time.now,
      #location:   {:lat => 44, :lng => -73},
      #comment:    "on point Checking"
    #)

    #checkin_near = Checkin.create(
      #created_at: Time.now,
      #location:   {:lat => 41.106667, :lng => -72.935833},
      #comment:    "Near checkin"
    #)

    #puts "Number of total checkings: " + Checkin.count.inspect
    puts "Number of total checkings: " + Checkin.all.to_a.inspect
    puts "Checkins around my initial checking: " + Checkin.where(:location.near => [[-73,44], 10000000]).count.inspect

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
    Checkin.create_indexes 'location'
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
            location:   {:lat => downtown_austin[0] + lat * 0.001, :lng => downtown_austin[1] + lon * 0.001},
            comment:    "Downtown Austin #{lat} #{lon}"
          )
        end
      end
    end

    "done"
  end
end
