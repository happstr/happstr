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

  get '/prototype' do
    send_file File.join(settings.public_folder, 'html/beta.html')
  end

  get '/beta' do
    redirect '/prototype'
  end

  get '/map' do
    send_file File.join(settings.public_folder, 'html/map.html')
  end

  get '/api/checkins' do
    # validate parameters
    lat = params[:lat]
    lon = params[:lon]
    range = (params[:range] || 500).to_i

    # austin debug
    #lat, lon = [30.264924, -97.741413]

    unless lat && (-180..180).cover?(lat.to_i) &&
           lon && (-180..180).cover?(lon.to_i)
           #range && (0..10000).cover?(range)
      "Uhm ... you need to pass ?lat=&long= betwen -180..180 and optional range"
    else
      Checkin.where(:source.near => [[lat, lon], range]).limit(200).to_a.to_json
    end
  end


  post '/api/checkins' do
    data = { created_at: Time.now }

    lat = params[:lat]
    lon = params[:lon]
    if lat && lon
      data.merge!({lat: lat, lon: lon})
    end

    comment = params[:comment]
    if comment
      data.merge!({comment: comment})
    end

    Checkin.create(data).to_json
  end

  put '/api/checkins/:id' do
    # check incoming data
    data = {}

    lat = params[:lat]
    lon = params[:lon]
    if lat && lon
      data.merge!({source: [lat.to_f, lon.to_f]})
    end

    comment = params["comment"]
    if comment
      data.merge!({comment: comment})
    end

    # update data in store
    checkin = Checkin.where(_id: params[:id])
    checkin.update_all(data)
    checkin.to_json
  end

  #
  # Development helpers

  get '/dev/setup' do
    Checkin.create_indexes

    "done"
  end

  get '/dev/bootstrap' do
    return true # remove to actually run this

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
