module RPredict
  class Observer

    attr_accessor :name, :localization, :description, :geodetic,
                  :velocity, :position

    def initialize(latitude=0.0, longitude=0.0, altitude=0.0)

      @geodetic  = RPredict::Geodetic.new(latitude, longitude, altitude)
      @velocity  =  RPredict::Norad.vector_t()
      @position  =  RPredict::Norad.vector_t()
    end

    #param satellite  the satellite data.
    #param start The time where calculation should start.
    #param maxdt The upper time limit in days (30 day limit)
    #return The time of the next AOS or 0.0 if the satellite has no AOS.

    def find_AOS (satellite, start, maxdt=30.0)

      timeStart = start
      aostime = 0.0

      # make sure current satellite values are
      #    in sync with the time
      #

      # check whether satelliteellite has aos #
      if !RPredict::OrbitTools.geostationary?(satellite) &&
         !RPredict::OrbitTools.decayed?(satellite) &&
         RPredict::OrbitTools.has_AOS?(satellite, self)

        satellite = calculate(satellite, start)

        if (satellite.ephemeris.elevation > 0.0)
           timeStart = find_LOS(satellite, start, maxdt) + 0.014 # +20 min
        end

        # invalid time (potentially returned by find_los) #
        if (timeStart >= 0.1)

          # update satelliteellite data #
          satellite = calculate(satellite, timeStart)

          # use upper time limit #
          # coarse time steps #
          while ((satellite.ephemeris.elevation < -1.0) && (timeStart <= (start + maxdt)))
              timeStart -= 0.00035 * (satellite.ephemeris.elevation * ((satellite.geodetic.altitude / 8400.0) + 0.46) - 2.0)
              satellite = calculate(satellite, timeStart)
          end

          # fine steps #
          while ((aostime == 0.0) && (timeStart <= (start + maxdt)))

              if ((satellite.ephemeris.elevation).abs < 0.005)
                  aostime = timeStart
              else
                  timeStart -= satellite.ephemeris.elevation * Math::sqrt(satellite.geodetic.altitude) / 530000.0
                  ephemeris  = calculate(satellite, timeStart)
              end

          end
        end
      end
      aostime
    end

    def find_LOS (satellite, start, maxdt=30.0)

      timeStart = start
      lostime   = 0.0

      # check whether satellite has aos
      if !RPredict::OrbitTools.geostationary?(satellite) &&
         !RPredict::OrbitTools.decayed?(satellite,timeStart) &&
          RPredict::OrbitTools.has_AOS?(satellite, self)

        satellite = calculate(satellite, start)

        if (satellite.ephemeris.elevation < 0.0)
            timeStart = find_AOS(satellite, start, maxdt) + 0.001 # +1.5 min
        end
        # invalid time (potentially returned by find_aos)
        if (timeStart >= 0.01)

          # update satelliteellite data
          satellite = calculate(satellite, timeStart)

          # use upper time limit

          # coarse steps
          while ((satellite.ephemeris.elevation >= 1.0) && (timeStart <= (start + maxdt)))
              timeStart += Math::cos(RPredict::SGPMath.deg2rad(satellite.ephemeris.elevation - 1.0)) * Math::sqrt(satellite.geodetic.altitude) / 25000.0
              satellite = calculate(satellite, timeStart)
          end
          # fine steps
          while ((lostime == 0.0) && (timeStart <= (start + maxdt)))

              timeStart += satellite.ephemeris.elevation * Math::sqrt(satellite.geodetic.altitude)/502500.0
              satellite = calculate(satellite, timeStart)

              if ((satellite.ephemeris.elevation).abs < 0.005)
                  lostime = timeStart
              end
          end
        end
      end
      lostime
    end

    #Find AOS time of current pass.
    # param satellite The satellite to find AOS for.
    # param start Start time, prefereably now.
    # return The time of the previous AOS or 0.0 if the satellite has no AOS.
    # This function can be used to find the AOS time in the past of the
    # current pass.
    #

    def findPrevAOS(satellite, start)

        aostime = start

        satellite = calculate(satellite,start)

        # check whether satellite has aos
        if !RPredict::OrbitTools.geostationary?(satellite) &&
         !RPredict::OrbitTools.decayed?(satellite,start) &&
          RPredict::OrbitTools.has_AOS?(satellite, self)

          while (satellite.ephemeris.elevation >= 0.0)
              aostime -= 0.0005 # 45 sec
              satellite = calculate(satellite,aostime)
          end
        else
          aostime = 0.0
        end
        aostime
    end

    def calculate(satellite,time)

      @geodetic.to_rad
      @geodetic.altitude /= 1000.0
      @geodetic.theta = 0

      jul_utc = time
      jul_epoch = RPredict::DateUtil.julian_Date_of_Epoch(satellite.tle.epoch)

      tsince = (jul_utc - jul_epoch) * RPredict::Norad::XMNPDA
      age = jul_utc - jul_epoch

      # call the norad routines according to the deep-space flag
      satellite.localization(tsince)

      RPredict::SGPMath.convert_Sat_State(satellite.position, satellite.velocity)

      # get the velocity of the satellite

      satellite.velocity.w = RPredict::SGPMath.magnitude(satellite.velocity)

      ephemeris = calculate_Obs(jul_utc,satellite)
      calculate_LatLonAlt(jul_utc,satellite)

      while (satellite.geodetic.longitude < -Math::PI)
          satellite.geodetic.longitude += RPredict::Norad::TWOPI
      end

      while (satellite.geodetic.longitude > (Math::PI))
          satellite.geodetic.longitude -= RPredict::Norad::TWOPI
      end
      ephemeris.azimuth   = RPredict::SGPMath.rad2deg(ephemeris.azimuth)
      ephemeris.elevation = RPredict::SGPMath.rad2deg(ephemeris.elevation)

      satellite.ssplat = RPredict::SGPMath.rad2deg(satellite.geodetic.latitude)
      satellite.ssplon = RPredict::SGPMath.rad2deg(satellite.geodetic.longitude)

      satellite.phase = RPredict::SGPMath.rad2deg(satellite.phase)

      # same formulas, but the one from predict is nicer
      #satellite.footprint = 2.0 * RPredict::Norad::XKMPER * acos (RPredict::Norad::XKMPER/satellite.position.w)

      satellite.footprint = 12756.33 * Math::acos(RPredict::Norad::XKMPER /
                            (RPredict::Norad::XKMPER+satellite.geodetic.altitude))

      satellite.orbit = ((satellite.tle.xno * RPredict::Norad::XMNPDA /
                          RPredict::Norad::TWOPI + age * satellite.tle.bstar *
                          RPredict::Norad::AE) * age + satellite.tle.xmo /
                          RPredict::Norad::TWOPI).floor + satellite.tle.revnum - 1

      @geodetic.to_deg
      @geodetic.altitude *= 1000.0
      satellite.ephemeris = ephemeris
      satellite
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
      # posend, and velocity, velend, from location {geodeticend at {timeend.
      # The {ephemerisend returned for Calculate_Obs consists of azimuth,
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
