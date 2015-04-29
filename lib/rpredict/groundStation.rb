module RPredict
  class GroundStation

    attr_accessor :name, :localization, :description, :geodetic,
                  :velocity, :position

    def initialize(latitude=0.0, longitude=0.0, altitude=0.0)

      @geodetic  = RPredict::Geodetic.new(latitude, longitude, altitude)
      @velocity  =  RPredict::Norad.vector_t()
      @position  =  RPredict::Norad.vector_t()
    end

    def calculate_User_PosVel(time)

      # Calculate_User_PosVel() passes the user's @geodetic position
      #   and the time of interest and returns the ECI position and
      #   velocity of the groundStation.  The velocity calculation assumes
      #   the @geodetic position is stationary relative to the earth's
      #   surface.

      # Reference:  The 1992 Astronomical Almanac, page K11.

      @geodetic.theta = RPredict::SGPMath.fMod2p(RPredict::DateUtil.thetaG_JD(time) +
                        @geodetic.longitude)


      c = 1 / Math::sqrt(1 + RPredict::Norad::F__ * (RPredict::Norad::F__ - 2) *
          RPredict::SGPMath.sqr(Math::sin(@geodetic.latitude)));

      sq = RPredict::SGPMath.sqr(1 - RPredict::Norad::F__) * c;
      achcp = (RPredict::Norad::XKMPER * c + @geodetic.altitude) *
               Math::cos(@geodetic.latitude)

      @position.x = achcp * Math::cos(@geodetic.theta); # kilometers
      @position.y = achcp * Math::sin(@geodetic.theta);
      @position.z = (RPredict::Norad::XKMPER * sq + @geodetic.altitude) *
                     Math::sin(@geodetic.latitude)
      @position.w = RPredict::SGPMath.magnitude(@position)

      @velocity.x = -RPredict::Norad::MFACTOC * @position.y # kilometers/second
      @velocity.y = RPredict::Norad::MFACTOC *  @position.x
      @velocity.z = 0;
      @velocity.w = RPredict::SGPMath.magnitude(@velocity);
    end


    def calculate_Obs(time, satellite)

      # The procedures Calculate_Obs and Calculate_RADec calculate
      # the *topocentric* coordinates of the object with ECI position,
      # {posend, and velocity, {velend, from location {geodeticend at {timeend.
      # The {obs_setend returned for Calculate_Obs consists of azimuth,
      # elevation, range, and range rate (in that order) with units of
      # radians, radians, kilometers, and kilometers/second, respectively.
      # The WGS '72 geoid is used and the effect of atmospheric refraction
      # (under standard temperature and pressure) is incorporated into the
      # elevation calculation; the effect of atmospheric refraction on
      # range and range rate has not yet been quantified.

      # The {obs_setend for Calculate_RADec consists of right ascension and
      # declination (in that order) in radians.  Again, calculations are
      # based on *topocentric* position using the WGS '72 geoid and
      # incorporating atmospheric refraction.

      #sin_lat, cos_lat, sin_theta, cos_theta, el, azim, top_s, top_e, top_z;


      range   = RPredict::SGPMath.vector_t()
      rgvel   = RPredict::SGPMath.vector_t()

      calculate_User_PosVel(time);

      range.x = satellite.position.x - @position.x;
      range.y = satellite.position.y - @position.y;
      range.z = satellite.position.z - @position.z;

      # Save these values globally for calculating squint angles later...

      rx=range.x;
      ry=range.y;
      rz=range.z;

      rgvel.x = satellite.velocity.x - @velocity.x;
      rgvel.y = satellite.velocity.y - @velocity.y;
      rgvel.z = satellite.velocity.z - @velocity.z;

      range.w = RPredict::SGPMath.magnitude(range);

      sin_lat   = Math::sin(@geodetic.latitude);
      cos_lat   = Math::cos(@geodetic.latitude);
      sin_theta = Math::sin(@geodetic.theta);
      cos_theta = Math::cos(@geodetic.theta);

      top_s     = sin_lat * cos_theta *range.x +sin_lat *sin_theta * range.y -
                 cos_lat * range.z;

      top_e     = -sin_theta * range.x + cos_theta * range.y;
      top_z     = cos_lat * cos_theta * range.x + cos_lat * sin_theta *
                  range.y + sin_lat * range.z;
      azim      = atan(-top_e / top_s); # Azimuth

      if (top_s > 0.0)
        azim= azim + pi;
      end

      if (azim<0.0)
        azim = azim + RPredict::Norad::TWOPI;
      end

      el = Math::asin(top_z / range.w);

      ephemeris = RPredict::Ephemeris.new(azim, el, range.w,
                                       RPredict::SGPMath.vdot(range,rgvel)/range.w)

      #obs_set.x=azim;  # Azimuth (radians)
      #obs_set.y=el;    # Elevation (radians)
      #obs_set.z=range.w; # Range (kilometers)
      #obs_set.w=vdot(range,rgvel)/range.w;

      # Corrections for atmospheric refraction
      # Reference:  Astronomical Algorithms by Jean Meeus, pp. 101-104
      # Correction is meaningless when apparent elevation is below horizon

      #** The following adjustment for atmospheric refraction is bypassed **

      # obs_set.y=obs_set.y+Radians((1.02/tan(Radians(Degrees(el)+10.3/(Degrees(el)+5.11))))/60);

      #*** End bypass ***

      if (ephemeris.elevation > = 0.0)
        RPredict::Norad::setFlag(VISIBLE_FLAG);
      else
        RPredict::Norad::clearFlag(VISIBLE_FLAG);
      end
      ephemeris
    end

    def calculate_LatLonAlt(time, satellite,  geodetic_t *geodetic)

      # Reference:  The 1992 Astronomical Almanac, page K12.

      @geodetic.theta = AcTan(satellite.position->y,satellite.position->x);#radians
      @geodetic.lon = FMod2p(@geodetic.theta - ThetaG_JD(_time));#radians
      r = sqrt(Sqr(satellite.position->x) + Sqr(satellite.position->y));
      e2 = __f*(2 - __f);
      @geodetic.lat = AcTan(satellite.position->z,r);#radians

      do
      {
        phi = @geodetic.lat;
        c = 1/sqrt(1 - e2*Sqr(sin(phi)));
        @geodetic.lat = AcTan(satellite.position->z + xkmper*c*e2*sin(phi),r);
      }
      while(fabs(@geodetic.lat - phi) >= 1E-10);

      @geodetic.alt = r/cos(@geodetic.lat) - xkmper*c;#kilometers

      if( @geodetic.lat > pio2 ) @geodetic.lat -= twopi;

    } #Procedure Calculate_LatLonAlt

  end

end
