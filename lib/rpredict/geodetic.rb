require 'date'

module RPredict
  class Geodetic

    attr_accessor :theta, :latitude, :longitude, :altitude, :dtime
    def initialize(latitude=0.0, longitude=0.0, altitude=0.0,theta=0.0,
                   dtime = RPredict::DateUtil.julianday_DateTime(DateTime.now))
      @theta = theta
      @latitude = latitude
      @longitude = longitude
      @altitude = altitude
      @dtime    = dtime

    end

    def to_rad
      @latitude  = RPredict::SGPMath.deg2rad(@latitude)
      @longitude = RPredict::SGPMath.deg2rad(@longitude)
    end

    def to_deg
      @latitude  = RPredict::SGPMath.rad2deg(@latitude)
      @longitude = RPredict::SGPMath.rad2deg(@longitude)
    end

  end
end
