module RPredict
  class Geodetic

    attr_accessor :theta, :latitude, :longitude, :altitude
    def initialize(latitude=0.0, longitude=0.0, altitude=0.0,theta=0.0)
      @theta = theta
      @latitude = latitude
      @longitude = longitude
      @altitude = altitude

    end

  end
end
