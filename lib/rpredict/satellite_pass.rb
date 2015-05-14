module RPredict
  class SatellitePass

    attr_accessor :observer,:satellite,:startDTime,:stopDTime,
                  :ephemerisAOS, :ephemerisTCA, :ephemerisLOS

     def initialize( observer,satellite,startDTime)

      @observer   = observer
      @satellite  = satellite
      @startDTime = startDTime

    end



  end
end