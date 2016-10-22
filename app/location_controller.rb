class LocationController
  attr_accessor :foursquare_client

  def initialize(foursquare_client)
    @foursquare_client = foursquare_client
  end

  def most_recent_location
    checkins = foursquare_client.user_checkins(limit: 1)
    if checkins.nil?
      NilLocation.new
    else
      Location.new(checkins.items.first)
    end
  end

  private

  def contains_valid_checkin?(checkins)
    !(checkins.nil? && checkins.compact.uniq.count.zero?)
  end
end

class Location
  attr_accessor :pretty_name

  attr_accessor :time_zone_offset
  attr_accessor :time_zone_offset_hours
  attr_accessor :time_zone_offset_minutes

  def initialize(checkin)
    location = checkin.venue.location
    @pretty_name = "#{location.city}, #{location.state}, #{location.country}"
    @time_zone_offset = checkin.timeZoneOffset
    @time_zone_offset_hours = (checkin.timeZoneOffset / 60).floor
    @time_zone_offset_minutes = checkin.timeZoneOffset % 60
  end

  def to_json
    {
      pretty_name: pretty_name,
      time_zone_offset: time_zone_offset,
      time_zone_offset_hours: time_zone_offset_hours,
      time_zone_offset_minutes: time_zone_offset_minutes,
    }.to_json
  end
end

class NilLocation < Location
  def initialize
    @pretty_name = 'Unkown Location'
  end
end
