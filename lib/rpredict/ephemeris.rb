module RPredict
  class Ephemeris

    attr_accessor :elevation, :azimuth, :range, :range_rate

     def initialize(elevation = 0.0, azimuth = 0.0,range = 0.0,range_rate = 0.0)
      @elevation  = elevation
      @azimuth    = azimuth
      @range      = range
      @range_rate = range_rate
     end
  end
end