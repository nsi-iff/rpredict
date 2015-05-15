module RPredict
  class SatellitePass

    attr_accessor :observer,:satelliteAOS, :satelliteTCA, :satelliteLOS

    def initialize( observer,satelliteAOS,satelliteLOS)

      @observer      = observer
      @satelliteAOS  = satelliteAOS
      @satelliteLOS  = satelliteLOS

    end
  end
end