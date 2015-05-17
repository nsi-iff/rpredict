module RPredict
  class SatellitePass

    attr_accessor :observer,:satellite, :ephemerisAOS, :ephemerisTCA, :ephemerisLOS

    def initialize( observer,satellite,ephemerisAOS,ephemerisLOS,ephemerisTCA)

      @observer      = observer
      @satellite     = satellite
      @ephemerisAOS  = ephemerisAOS
      @ephemerisLOS  = ephemerisLOS
      @ephemerisTCA  = ephemerisTCA

    end
  end
end