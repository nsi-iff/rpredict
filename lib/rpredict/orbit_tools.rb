require 'matrix'

module RPredict
  module OrbitTools
    extend self
    include Math

    def decayed?(satellite,time =0.0)
=begin
    tle.xndt2o/(twopi/xmnpda/xmnpda) is the value before converted the
    value matches up with the value in predict 2.2.3 */
    FIXME decayed is treated as a static quantity.
    It is time dependent. Also satellite->jul_utc is often zero
    when this function is called
=end
    #?????

      if time == 0.0
        time = RPredict::DateUtil.currentDaynum()
      end

      satepoch = RPredict::DateUtil.dayNum(1, 0, satellite.year) + satellite.refepoch;
      #if (satepoch + ((16.666666 - PLib.sat[x].meanmo) /
      #    (10.0 * Math.abs(PLib.sat[x].drag))) < time)

      if (satepoch + ((16.666666 - satellite.meanmo) /
         (10.0 *  (satellite.tle.xndt2o/RPredict::Norad::TXX).abs)) < time)
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

  end
end