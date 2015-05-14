require 'matrix'

module RPredict
  module OrbitTools
    extend self
    include Math


    def decayed?(satellite,time =0.0)

    #?????

      if time == 0.0
        time = RPredict::DateUtil.currentDayTime()
      end

      satepoch = RPredict::DateUtil.julian_Date_of_Epoch(satellite.tle.epoch)

      if satepoch + ((16.666666 - satellite.meanmo) /
         (10.0 *  (satellite.drag.abs))) < time
        #satellite.tle.xndt2o/RPredict::Norad::TXX).abs)

        true
      else

        false
      end
    end

    def geostationary?(satellite)

      if ((satellite.meanmo - 1.0027).abs < 0.0002)
          true
      else

          false
      end
    end

    def has_AOS?(satellite, observer)

      if (satellite.meanmo != 0.0)

        # xincl is already in RAD by select_ephemeris
        lin = satellite.tle.incliniation
        if (lin >= 90.0)
             lin = 180.0 - lin
        end
        sma = 331.25 * Math::exp(Math::log(1440.0/satellite.meanmo) * (2.0/3.0))
        apogee = sma * (1.0 + satellite.tle.eo) - RPredict::Norad::XKMPER

        if (Math::acos(RPredict::Norad::XKMPER/(apogee+RPredict::Norad::XKMPER))+
            RPredict::SGPMath.deg2rad(lin)) > (RPredict::SGPMath.deg2rad(observer.geodetic.latitude).abs)

           return true
        end
      end

      return false
    end

  end
end