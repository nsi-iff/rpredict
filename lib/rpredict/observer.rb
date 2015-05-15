module RPredict
  class Observer

    attr_accessor :name, :localization, :description, :geodetic,
                  :velocity, :position

    def initialize(latitude=0.0, longitude=0.0, altitude=0.0)

      @geodetic  = RPredict::Geodetic.new(latitude, longitude, altitude)
      @velocity  =  RPredict::Norad.vector_t()
      @position  =  RPredict::Norad.vector_t()
    end

    #param satelliteellite  the satellite data.
    #param start The time where calculation should start.
    #param maxdt The upper time limit in days (30 day limit)
    #return The time of the next AOS or 0.0 if the satellite has no AOS.

    def findAOS(satellite, start, maxdt=30.0, elevationIni = 0.0)

      timeStart = start
      satellite = calculate(satellite, start)
      satellite.ephemeris.dateTime = 0.0

      # make sure current satellite values are
      #    in sync with the time
      #

      # check whether satelliteellite has aos #
      if !RPredict::OrbitTools.geostationary?(satellite) &&
         !RPredict::OrbitTools.decayed?(satellite) &&
         RPredict::OrbitTools.has_AOS?(satellite, self)

        if (satellite.ephemeris.elevation > elevationIni)
           timeStart = (findLOS(satellite, start, maxdt)).ephemeris.dateTime + 0.014 # +20 min
        end

        # invalid time (potentially returned by findLOS) #
        if (timeStart >= 0.1)

          # update satelliteellite data #
          satellite = calculate(satellite, timeStart)

          # use upper time limit #
          # coarse time steps #
          while ((satellite.ephemeris.elevation < (elevationIni-1.0)) && (timeStart <= (start + maxdt)))
              timeStart -= 0.00035 * (satellite.ephemeris.elevation *
                           ((satellite.geodetic.altitude / 8400.0) + 0.46) - 2.0)
              satellite = calculate(satellite, timeStart)
          end

          # fine steps #
          while ((satellite.ephemeris.elevation.abs >= (elevationIni+0.005)) && (timeStart <= (start + maxdt)))
            timeStart -= satellite.ephemeris.elevation * Math::sqrt(satellite.geodetic.altitude) / 530000.0
            satellite  = calculate(satellite, timeStart)
          end
        end
      end
      satellite
    end

    def findLOS (satellite, start, maxdt=30.0)

      timeStart = start
      satellite = calculate(satellite, start)
      satellite.ephemeris.dateTime = 0.0

      # check whether satellite has aos
      if !RPredict::OrbitTools.geostationary?(satellite) &&
         !RPredict::OrbitTools.decayed?(satellite,timeStart) &&
          RPredict::OrbitTools.has_AOS?(satellite, self)

        if (satellite.ephemeris.elevation < 0.0)
            timeStart = (findAOS(satellite, start, maxdt)).ephemeris.dateTime + 0.001 # +1.5 min
        end
        # invalid time (potentially returned by findAOS)
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
          while (((satellite.ephemeris.elevation).abs >= 0.005) && (timeStart <= (start + maxdt)))

              timeStart += satellite.ephemeris.elevation * Math::sqrt(satellite.geodetic.altitude)/502500.0
              satellite = calculate(satellite, timeStart)
          end
        end
      end
      satellite
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
        satellite.ephemeris.dateTime = 0.0

        # check whether satellite has aos
        if !RPredict::OrbitTools.geostationary?(satellite) &&
         !RPredict::OrbitTools.decayed?(satellite,start) &&
          RPredict::OrbitTools.has_AOS?(satellite, self)

          while (satellite.ephemeris.elevation >= 0.0)
              aostime -= 0.0005 # 45 sec
              satellite = calculate(satellite,aostime)
          end
        end
        satellite
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

      satellite.calculate_LatLonAlt(jul_utc)

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
      # posend, and velocity, velend, from location geodeticend at timeend.
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

      if (ephemeris.elevation >= 0.0)
        satellite = RPredict::Norad::setFlag(satellite, RPredict::Norad::VISIBLE_FLAG)
      else
        satellite = RPredict::Norad::clearFlag(satellite,RPredict::Norad::VISIBLE_FLAG)
      end
      ephemeris
    end
=begin
    def getPass   (satellite, start, maxdt)


        tca  = 0.0    # time of TCA
        #los  = 0.0    # time of LOS
        dt   = 0.0    # time diff
        step = 0.0    # time step
        iter = 0      # number of iterations
        t0   = start
        done = false

        tres = 0.0 # required time resolution
        max_el = 0.0 # maximum elevation
        satellitePass =
        detail = NULL



        # FIXME: watchdog

        # get time resolution satellite-cfg stores it in seconds

        tres = RPredict::Norad::SAT_CFG_INT_PRED_RESOLUTION / 86400.0

        # loop until we find a pass with elevation > SAT_CFG_INT_PRED_MIN_EL
        #    or we run out of time
        #    FIXME: we should have a safety break

        while (!done)

            # Find los of next pass or of current pass
            satelliteLOS = findLOS(satellite, t0, maxdt) # See if a pass is ongoing
            satelliteAOS = findAOS(satellite, t0, maxdt)

            if (satelliteAOS.ephemeris.dateTime > satelliteLOS.ephemeris.dateTime)
                # satelliteLOS.ephemeris.dateTime is from an currently happening pass, find previous satelliteAOS.ephemeris.dateTime
                satelliteAOS = findPrevAOS(satellite, t0)
            end

            # satelliteAOS.ephemeris.dateTime = 0.0 means no satelliteAOS.ephemeris.dateTime
            if (satelliteAOS.ephemeris.dateTime == 0.0)
                done = true
                next
            end

            # check whether we are within time limits
            # maxdt = 0 mean no time limit.

            else
            if ((maxdt > 0.0) && (satelliteAOS.ephemeris.dateTime > (start + maxdt)) )
                done = true

            else

                dt = satelliteLOS.ephemeris.dateTime - satelliteAOS.ephemeris.dateTime

                # get time step, which will give us the max number of entries

                step = dt / RPredict::Norad::SAT_CFG_INT_PRED_NUM_ENTRIES

                # but if this is smaller than the required resolution
                #    we go with the resolution

                if (step < tres)
                    step = tres
                end

                satelitePass = RPredict::SatellitePass.new(self,satelliteAOS,satelliteLOS)

                # create a pass_t entry FIXME: g_try_new in 2.8

                # iterate over each time step
                for (t = pass->satelliteAOS.ephemeris.dateTime t <= pass->satelliteLOS.ephemeris.dateTime t += step)

                    # calculate satelliteellite data
                    satellite = calculate(satellite, satelliteAOS.ephemeris.dateTime)

                    # in the first iter we want to store
                    #    pass->satelliteAOS.ephemeris.dateTime_az

                    if (t == pass->satelliteAOS.ephemeris.dateTime)
                        pass->satelliteAOS.ephemeris.dateTime_az = satellite->az
                        pass->orbit = satellite->orbit
                    end

                    # append details to satellite->details
                    detail = g_new (pass_detail_t, 1)
                    detail->time = t
                    detail->pos.x = satellite->pos.x
                    detail->pos.y = satellite->pos.y
                    detail->pos.z = satellite->pos.z
                    detail->pos.w = satellite->pos.w
                    detail->vel.x = satellite->vel.x
                    detail->vel.y = satellite->vel.y
                    detail->vel.z = satellite->vel.z
                    detail->vel.w = satellite->vel.w
                    detail->velo = satellite->velo
                    detail->az = satellite->az
                    detail->el = satellite->el
                    detail->range = satellite->range
                    detail->range_rate = satellite->range_rate
                    detail->lat = satellite->ssplat
                    detail->lon = satellite->ssplon
                    detail->alt = satellite->alt
                    detail->ma = satellite->ma
                    detail->phase = satellite->phase
                    detail->footprint = satellite->footprint
                    detail->orbit = satellite->orbit
                    detail->vis = get_satellite_vis (satellite, qth, t)

                    # also store visibility "bit"
                    switch (detail->vis)
                    case SAT_VIS_VISIBLE:
                        pass->vis[0] = 'V'
                        break
                    case SAT_VIS_DAYLIGHT:
                        pass->vis[1] = 'D'
                        break
                    case SAT_VIS_ECLIPSED:
                        pass->vis[2] = 'E'
                        break
                    default:
                        break
                    end

                    pass->details = g_slist_prepend (pass->details, detail)

                    # store elevation if greater than the
                        previously stored one

                    if (satellite->el > max_el)
                        max_el = satellite->el
                        tca = t
                        pass->maxel_az = satellite->az
                    end

                    #     g_print ("TIME: %f\tAZ: %f\tEL: %f (MAX: %f)\n",
                    #           t, satellite->az, satellite->el, max_el)
                end

                pass->details = g_slist_reverse (pass->details)

                # calculate satelliteellite data
                satellite = calculate(satellite, pass->satelliteLOS.ephemeris.dateTime)
                # store satelliteLOS.ephemeris.dateTime_az, max_el and tca
 satelliteAOS.ephemeris.dateTime              pass->satelliteLOS.ephemeris.dateTime_az = satellite->az
                pass->max_el = max_el
                p#ass->tca    = tca

                # check whether this pass is good
                if (max_el >= satellite_cfg_get_int (SAT_CFG_INT_PRED_MIN_EL))
                    done = true
                end
                else
                    done = FALSE
                    t0 = satelliteLOS.ephemeris.dateTime + 0.014 // +20 min
                    free_pass (pass)
                    pass = NULL
                end

                iter++
          end
        end

        return pass
    end #getPass
=end
  end
end
