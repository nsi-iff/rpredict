module RPredict
  module Satellite
    class Satellite

      attr_accessor :tle, :ephemeris, :geodetic, :sgps, :dps, :deep_arg,
                    :flags, :phase, :position, :velocity, :meanmo, :footprint,
                    :orbit, :ssplat, :ssplon

      def initialize(name,line1,line2)
        @tle        = RPredict::Satellite::TLE.new(name,line1,line2)
        @sgps       = RPredict::Norad.sgpsdp_static_t()
        @dps        = RPredict::Norad.deep_static_t()
        @deep_arg   = RPredict::Norad.deep_arg_t()
        @flags      = 0

        @geodetic   = RPredict::Geodetic.new
        @velocity   =  RPredict::Norad.vector_t()
        @position   =  RPredict::Norad.vector_t()

      end

      def localization(tsince)
        if (@flags & RPredict::Norad::DEEP_SPACE_EPHEM_FLAG) != 0

            RPredict::SGPSDP.sdp4(self, tsince)
        else

            RPredict::SGPSDP.sgp4(self, tsince)

        end
      end

      def select_ephemeris()

        # Preprocess tle set

        @tle.xnodeo = RPredict::SGPMath.deg2rad(@tle.xnodeo)
        @tle.omegao = RPredict::SGPMath.deg2rad(@tle.omegao)
        @tle.xmo    = RPredict::SGPMath.deg2rad(@tle.xmo)
        @tle.xincl  = RPredict::SGPMath.deg2rad(@tle.xincl)

        temp = RPredict::Norad::TXX

        # store mean motion beforersion
        @meanmo = @tle.xno
        @tle.xno = @tle.xno * temp * RPredict::Norad::XMNPDA
        @tle.xndt2o *= temp
        @tle.xndd6o = @tle.xndd6o * temp / RPredict::Norad::XMNPDA
        @tle.bstar /= RPredict::Norad::AE

        #Period > 225 minutes is deep space
        dd1  =  (RPredict::Norad::XKE  / @tle.xno)
        a1   =  dd1**RPredict::Norad::TOTHRD
        r1   =  Math::cos(@tle.xincl)
        dd1  =  (1.0 - (@tle.eo ** 2))
        temp  =  RPredict::Norad::CK2 * 1.5 * (r1 * r1 * 3.0 - 1.0) / (dd1**1.5)
        del1  =  temp / (a1 * a1)
        ao    =  a1 * (1.0 - del1 * (RPredict::Norad::TOTHRD * 0.5 + del1 *
               (del1 * 1.654320987654321 + 1.0)))

        xnodp  =  @tle.xno / ((temp / (ao * ao)) + 1.0)

        if ((RPredict::Norad::TWOPI / xnodp / RPredict::Norad::XMNPDA) >=  0.15625)
          @flags |= RPredict::Norad::DEEP_SPACE_EPHEM_FLAG
        else
          @flags &= ~RPredict::Norad::DEEP_SPACE_EPHEM_FLAG
        end

      end

      def calculate_LatLonAlt(time)

        # Reference:  The 1992 Astronomical Almanac, page K12.

        @geodetic.theta     = RPredict::SGPMath.acTan(@position.y,@position.x)#radians
        @geodetic.longitude = RPredict::SGPMath.fMod2p(@geodetic.theta -
                                      RPredict::DateUtil.thetaG_JD(time))#radians
        r = Math::sqrt(RPredict::SGPMath.sqr(@position.x) +
            RPredict::SGPMath.sqr(@position.y))

        e2 = RPredict::Norad::F__*(2 - RPredict::Norad::F__)

        @geodetic.latitude = RPredict::SGPMath.acTan(@position.z,r)#radians

        begin

          phi = @geodetic.latitude
          c = 1/Math::sqrt(1 - e2 * RPredict::SGPMath.sqr(Math::sin(phi)))
          @geodetic.latitude = RPredict::SGPMath.acTan(@position.z +
                                        RPredict::Norad::XKMPER * c * e2 * Math::sin(phi),r)

        end while((@geodetic.latitude - phi).abs >= 1E-10)

        @geodetic.altitude = r/Math::cos(@geodetic.latitude) -
                                  RPredict::Norad::XKMPER * c #kilometers

        if(@geodetic.latitude > RPredict::Norad::PIO2 )
           @geodetic.latitude -= RPredict::Norad::TWOPI
        end
        #satellite
      end #Procedure Calculate_LatLonAlt

      def veloc
        @velocity.w
      end

      def catnum
        @tle.satellitenumber
      end

      def setnum
        @tle.elementnumber
      end

      def designator
        @tle.internationaldesignator
      end

      def year
        @tle.epochyear
      end

      def refepoch
        @tle.epochday
      end

      def incl
        @tle.incliniation
      end

      def raan
        @tle.rightascensionascendingnode
      end

      def eccn
        @tle.eo
      end

      def argper
        @tle.argumentperigge
      end

      def meanan
        @tle.meananomaly
      end

      def meanmo
        @tle.meanmotion
      end

      def drag
        @tle.firstderivativmeanmotion
      end


      def nddot6
        #@tle.secondderivativemeanmotion
        (@tle.nddot6)
      end

      def bstar
        #@tle.bstardrag
        (@tle.bstar)
      end

      def orbitnum
        @tle.revolutionnumberepoch
      end

    end
  end
end
