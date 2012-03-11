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
    field :comment,    :type => String

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
      Checkin.where(:source.near => [[lat, lon], range]).limit(500).to_a.to_json
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

  get '/latest' do
    css = <<CSS
    body {
      font-size: 100%;
      font-family: 'BentonSans','Lucida Grande', 'Lucida Sans', Arial, sans-serif;
      background: url(/img/launch/bg.png) #d7eff4;
      color: #366670;
      }

    ul {
        width: 30em;
        margin: 0 auto;
        list-style-type: none
        }

    li {
        padding: .5em 0 1em 0;
        margin: .5em;
        border-bottom: 1px dotted #98C5CE;
        line-height: 1.5em
        }

    div p { 
        width: 30em;
        margin: 0 auto;
        padding: .5em;
    }
    
    @font-face {
      font-family: 'Freehand575';
      src: url('/fonts/208F23_0_0.eot'),
           url('/fonts/208F23_0_0.eot?#iefix') format('embedded-opentype'),
           url('/fonts/208F23_0_0.woff') format('woff'),
           url('/fonts/208F23_0_0.ttf') format('truetype');
           }

    h1 {
        font-family: 'Freehand575', Georgia, serif;
        font-size: 1.2em;
        width: 21em;
        margin: 1em auto;
        color: #DF55A0;
        }

    div p {
        font-size: .8em;
        }

    li p {
        margin-top: 0;
        font-size: 1.2em;
        margin-bottom: .2em
        }

    li span {
        font-size: .8em;
        }
CSS
    
    "<html><head><style>" + css + "</style></head><body>" +
    "<h1>The latest and greatest Happstr tap-ins</h1>" +
    "<div><p>total " + Checkin.count.to_s + "</p>" +
    "<p>with location " + Checkin.where(:source.exists => true).count.to_s + "</p>" +
    "<p>with comment " + Checkin.where(:comment.exists => true).count.to_s + "</p>" +    
    "<p>with comment & location " + Checkin.where(:source.exists => true, :comment.exists => true).count.to_s + "</p></div>" +        
    "<ul>" +
      Checkin.where(:comment.exists => true).order_by({created_at: -1}).limit(200).to_a.select do |checkin|
        checkin.comment != ''
      end.map do |checkin|
        "<li><p>#{checkin.comment}\t</p> <span>#{Time.at(checkin.created_at.to_i - 0).strftime("%B %d, %Y @ %H:%M")}</span></li>"
      end.join("\n") + "</ul>" +
    "</body></html>"
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
