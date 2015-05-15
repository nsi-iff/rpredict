module RPredict
  class Ephemeris

    attr_accessor :elevation, :azimuth, :range, :range_rate, :observer,
                  :satellite, :dateTime

     def initialize( observer,satellite, azimuth = 0.0,elevation = 0.0,
                     range = 0.0,range_rate = 0.0, dateTime = 0.0)
      @observer   = observer
      @satellite  = satellite
      @elevation  = elevation
      @azimuth    = azimuth
      @range      = range
      @range_rate = range_rate
      @dateTime   = dateTime
     end
  end
end