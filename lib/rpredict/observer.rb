module RPredict
  class Observer

    attr_accessor :name, :localization, :description, :geodetic,
                  :velocity, :position

    def initialize(latitude=0.0, longitude=0.0, altitude=0.0)

      @geodetic  = RPredict::Geodetic.new(latitude, longitude, altitude)
      @velocity  =  RPredict::Norad.vector_t()
      @position  =  RPredict::Norad.vector_t()
    end

    def calc_ephemeris(satellite,time)

    end


    def calculate(satellite,time=DateTime.now)

      @geodetic.to_rad
      @geodetic.altitude /= 1000.0
      @geodetic.theta = 0

      satellite = RPredict::Norad.select_ephemeris(satellite)

      jul_utc = time
      jul_epoch = RPredict::DateUtil.julian_Date_of_Epoch(satellite.tle.epoch)

      tsince = (jul_utc - jul_epoch) * RPredict::Norad::XMNPDA
      age = jul_utc - jul_epoch



      # call the norad routines according to the deep-space flag

      if (satellite.flags & RPredict::Norad::DEEP_SPACE_EPHEM_FLAG) != 0
          satellite = RPredict::SGPSDP.sdp4(satellite, tsince)
      else
          satellite = RPredict::SGPSDP.sgp4(satellite, tsince)
      end

      #p "X : #{satellite.position.x} Y: #{satellite.position.y}"
      RPredict::SGPMath.convert_Sat_State(satellite.position, satellite.velocity)

      #p "X1: #{satellite.position.x} Y: #{satellite.position.y}"

      # get the velocity of the satellite

      satellite.velocity.w = RPredict::SGPMath.magnitude(satellite.velocity)

      #satellite.velo = satellite.vel.w

      satellite.ephemeris = calculate_Obs(jul_utc,satellite)
      calculate_LatLonAlt(jul_utc,satellite)



      while (satellite.geodetic.longitude < -Math::PI)
          satellite.geodetic.longitude += RPredict::Norad::TWOPI
      end

      while (satellite.geodetic.longitude > (Math::PI))
          satellite.geodetic.longitude -= RPredict::Norad::TWOPI
      end


      satellite.ephemeris.azimuth   = RPredict::SGPMath.rad2deg(satellite.ephemeris.azimuth)
      satellite.ephemeris.elevation = RPredict::SGPMath.rad2deg(satellite.ephemeris.elevation)

      satellite.ssplat = RPredict::SGPMath.rad2deg(satellite.geodetic.latitude)
      satellite.ssplon = RPredict::SGPMath.rad2deg(satellite.geodetic.longitude)

      satellite.phase = RPredict::SGPMath.rad2deg(satellite.phase)

      # same formulas, but the one from predict is nicer
      #satellite.footprint = 2.0 * RPredict::Norad::XKMPER * acos (RPredict::Norad::XKMPER/satellite.position.w)

      #p " az #{satellite.ephemeris.azimuth} el #{satellite.ephemeris.elevation} al #{satellite.geodetic.altitude}
           #{RPredict::Norad::XKMPER / (RPredict::Norad::XKMPER+satellite.geodetic.altitude)}"

      #satellite.footprint = 12756.33 * Math::acos(RPredict::Norad::XKMPER /
      #                      (RPredict::Norad::XKMPER+satellite.geodetic.altitude))



      satellite.orbit = ((satellite.tle.xno * RPredict::Norad::XMNPDA /
                          RPredict::Norad::TWOPI + age * satellite.tle.bstar *
                          RPredict::Norad::AE) * age + satellite.tle.xmo /
                          RPredict::Norad::TWOPI).floor + satellite.tle.revnum - 1

      @geodetic.to_deg
      @geodetic.altitude *= 1000.0

    end

    def calculate_User_PosVel(time)

      # Calculate_User_PosVel() passes the user's @geodetic position
      #   and the time of interest and returns the ECI position and
      #   velocity of the observer.  The velocity calculation assumes
      #   the @geodetic position is stationary relative to the earth's
      #   surface.

      # Reference:  The 1992 Astronomical Almanac, page K11.

      @geodetic.theta = RPredict::SGPMath.fMod2p(RPredict::DateUtil.thetaG_JD(time) +
                        @geodetic.longitude)


      factc = 1 / Math::sqrt(1 + RPredict::Norad::F__ * (RPredict::Norad::F__ - 2.0) *
           (Math::sin(@geodetic.latitude) ** 2))

      factsq = ((1 - RPredict::Norad::F__) ** 2) * factc
      achcp = (RPredict::Norad::XKMPER * factc + @geodetic.altitude) *
               Math::cos(@geodetic.latitude)

      @position.x = achcp * Math::cos(@geodetic.theta) # kilometers
      @position.y = achcp * Math::sin(@geodetic.theta)
      @position.z = (RPredict::Norad::XKMPER * factsq + @geodetic.altitude) *
                     Math::sin(@geodetic.latitude)
      @position.w = RPredict::SGPMath.magnitude(@position)

      @velocity.x = -RPredict::Norad::MFACTOR * @position.y # kilometers/second
      @velocity.y = RPredict::Norad::MFACTOR *  @position.x
      @velocity.z = 0
      @velocity.w = RPredict::SGPMath.magnitude(@velocity)
    end


    def calculate_Obs(time, satellite)

      # The procedures Calculate_Obs and Calculate_RADec calculate
      # the *topocentric* coordinates of the object with ECI position,
      # {posend, and velocity, {velend, from location {geodeticend at {timeend.
      # The {satellite.ephemerisend returned for Calculate_Obs consists of azimuth,
      # elevation, range, and range rate (in that order) with units of
      # radians, radians, kilometers, and kilometers/second, respectively.
      # The WGS '72 geoid is used and the effect of atmospheric refraction
      # (under standard temperature and pressure) is incorporated into the
      # elevation calculation the effect of atmospheric refraction on
      # range and range rate has not yet been quantified.

      # The {obs_setend for Calculate_RADec consists of right ascension and
      # declination (in that order) in radians.  Again, calculations are
      # based on *topocentric* position using the WGS '72 geoid and
      # incorporating atmospheric refraction.

      #sin_lat, cos_lat, sin_theta, cos_theta, el, azim, top_s, top_e, top_z


      range   = RPredict::Norad.vector_t()
      rgvel   = RPredict::Norad.vector_t()

      calculate_User_PosVel(time)

      range.x = satellite.position.x - @position.x
      range.y = satellite.position.y - @position.y
      range.z = satellite.position.z - @position.z

      # Save these values globally for calculating squint angles later...

      rx=range.x
      ry=range.y
      rz=range.z

      rgvel.x = satellite.velocity.x - @velocity.x
      rgvel.y = satellite.velocity.y - @velocity.y
      rgvel.z = satellite.velocity.z - @velocity.z

      range.w = RPredict::SGPMath.magnitude(range)

      sin_lat   = Math::sin(@geodetic.latitude)
      cos_lat   = Math::cos(@geodetic.latitude)

      sin_theta = Math::sin(@geodetic.theta)
      cos_theta = Math::cos(@geodetic.theta)

      top_s     = sin_lat * cos_theta * range.x + sin_lat * sin_theta * range.y -
                  cos_lat * range.z

      top_e     = -sin_theta * range.x + cos_theta * range.y
      top_z     = cos_lat * cos_theta * range.x + cos_lat * sin_theta *
                  range.y + sin_lat * range.z
      azim      = Math::atan(-top_e / top_s) # Azimuth

      if (top_s > 0.0)
        azim += Math::PI
      end

      if (azim<0.0)
        azim += RPredict::Norad::TWOPI
      end

      el = Math::asin(top_z / range.w)

      ephemeris = RPredict::Ephemeris.new(self, satellite, azim, el, range.w,
                                       RPredict::SGPMath.dot(range,rgvel)/range.w,
                                       time)


      #obs_set.x=azim  # Azimuth (radians)
      #obs_set.y=el    # Elevation (radians)
      #obs_set.z=range.w # Range (kilometers)
      #obs_set.w=vdot(range,rgvel)/range.w

      # Corrections for atmospheric refraction
      # Reference:  Astronomical Algorithms by Jean Meeus, pp. 101-104
      # Correction is meaningless when apparent elevation is below horizon

      #** The following adjustment for atmospheric refraction is bypassed **

      # obs_set.y=obs_set.y+Radians((1.02/tan(Radians(Degrees(el)+10.3/(Degrees(el)+5.11))))/60)

      #*** End bypass ***

      if (ephemeris.elevation >= 0.0)
        satellite = RPredict::Norad::setFlag(satellite, RPredict::Norad::VISIBLE_FLAG)
      else
        satellite = RPredict::Norad::clearFlag(satellite,RPredict::Norad::VISIBLE_FLAG)
      end
      ephemeris
    end

    def calculate_LatLonAlt(time, satellite)

      # Reference:  The 1992 Astronomical Almanac, page K12.

      satellite.geodetic.theta     = RPredict::SGPMath.acTan(satellite.position.y,satellite.position.x)#radians
      satellite.geodetic.longitude = RPredict::SGPMath.fMod2p(satellite.geodetic.theta -
                                    RPredict::DateUtil.thetaG_JD(time))#radians
      r = Math::sqrt(RPredict::SGPMath.sqr(satellite.position.x) +
          RPredict::SGPMath.sqr(satellite.position.y))

      e2 = RPredict::Norad::F__*(2 - RPredict::Norad::F__)

      satellite.geodetic.latitude = RPredict::SGPMath.acTan(satellite.position.z,r)#radians

      begin

        phi = satellite.geodetic.latitude
        c = 1/Math::sqrt(1 - e2 * RPredict::SGPMath.sqr(Math::sin(phi)))
        satellite.geodetic.latitude = RPredict::SGPMath.acTan(satellite.position.z +
                                      RPredict::Norad::XKMPER * c * e2 * Math::sin(phi),r)

      end while((satellite.geodetic.latitude - phi).abs >= 1E-10)

      satellite.geodetic.altitude = r/Math::cos(satellite.geodetic.latitude) -
                                RPredict::Norad::XKMPER * c #kilometers

      if(satellite.geodetic.latitude > RPredict::Norad::PIO2 )
         satellite.geodetic.latitude -= RPredict::Norad::TWOPI
      end
      #satellite
    end #Procedure Calculate_LatLonAlt

  end

end
