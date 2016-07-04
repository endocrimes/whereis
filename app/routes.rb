require 'sinatra/base'
require_relative 'location_controller'
require 'foursquare2'
require 'json'

class Whereis < Sinatra::Base
  attr_accessor :location_controller

  def initialize(
    location_controller = LocationController.new(
      Foursquare2::Client.new(oauth_token: ENV['FOURSQUARE_ACCESS_TOKEN'], api_version: '20160101')
    )
  )
    @location_controller = location_controller
    super
  end

  get '/' do
    erb :location, :locals => { :model => location }
  end

  get '/json' do
    body location.to_json
  end

  def location
    location_controller.most_recent_location
  end
end
