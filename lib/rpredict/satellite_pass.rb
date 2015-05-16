module RPredict
  class SatellitePass

    attr_accessor :observer,:satelliteAOS, :satelliteTCA, :satelliteLOS

    def initialize( observer,satelliteAOS,satelliteLOS,satelliteTCA)

      @observer      = observer
      @satelliteAOS  = satelliteAOS
      @satelliteLOS  = satelliteLOS
      @satelliteTCA  = satelliteTCA

    end
  end
end