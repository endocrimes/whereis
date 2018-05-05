require 'sinatra/base'
require 'foursquare2'
require 'mapbox-sdk'
require 'json'

require_relative 'location_controller'
require_relative 'person'

class Whereis < Sinatra::Base
  attr_accessor :location_controller
  attr_accessor :person
  attr_accessor :mapbox_token

  def initialize()
    foursquare_access_token = ENV['FOURSQUARE_ACCESS_TOKEN']
    foursquare_client = Foursquare2::Client.new(oauth_token: foursquare_access_token, api_version: '20160101')
    @location_controller = LocationController.new(foursquare_client)

    name = ENV['USER_NAME']
    pronoun = ENV['USER_PRONOUN']
    @person = Person.new(name, pronoun)

    @mapbox_token = ENV['MAPBOX_TOKEN']
    Mapbox.access_token = @mapbox_token
    super
  end

  get '/' do
    erb(:location, :locals => {:location => location,
                               :person => person,
                               :tokens => { :MAPBOX => mapbox_token }})
  end

  get '/json' do
    body(location.to_json)
  end

  def location
    location_controller.most_recent_location
  end
end
