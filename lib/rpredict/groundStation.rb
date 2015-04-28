module RPredict
  class GroundStation

    attr_accessor :name, :localization, :description, :geodetic,
                  :velocity, :position

    def initialize(latitude=0.0, longitude=0.0, altitude=0.0)

      @geodetic  = RPredict::Geodetic.new(latitude, longitude, altitude)
      @velocity  =  RPredict::Norad.vector_t()
      @position  =  RPredict::Norad.vector_t()
    end

    def calculate_User_PosVel(time, geodetic, obs_pos, obs_vel)

      # Calculate_User_PosVel() passes the user's geodetic position
      #   and the time of interest and returns the ECI position and
      #   velocity of the groundStation.  The velocity calculation assumes
      #   the geodetic position is stationary relative to the earth's
      #   surface.

      # Reference:  The 1992 Astronomical Almanac, page K11.

      geodetic.theta = RPredict::SGPMath.fMod2p(RPredict::Norad::ThetaG_JD(time)+geodetic.lon);


      c=1/Math::sqrt(1+f*(f-2)*RPredict::SGPMath.sqr(Math::sin(geodetic.lat)));
      sq=RPredict::SGPMath.sqr(1-f)*c;
      achcp=(xkmper*c+geodetic.alt)*Math::cos(geodetic.lat);
      obs_pos.x=achcp*Math::cos(geodetic.theta); # kilometers
      obs_pos.y=achcp*Math::sin(geodetic.theta);
      obs_pos.z=(xkmper*sq+geodetic.alt)*Math::sin(geodetic.lat);
      obs_vel.x=-mfactor*obs_pos.y; # kilometers/second
      obs_vel.y=mfactor*obs_pos.x;
      obs_vel.z=0;
      return RPredict::SGPMath.magnitude(obs_pos), RPredict::SGPMath.magnitude(obs_vel);
    end


    def calculate_Obs(time, pos, vel, geodetic, obs_set)

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

      obs_pos = RPredict::SGPMath.vector_t()
      obs_vel = RPredict::SGPMath.vector_t()
      range   = RPredict::SGPMath.vector_t()
      rgvel   = RPredict::SGPMath.vector_t()

      obs_pos,obs_vel = calculate_User_PosVel(time, geodetic, obs_pos, obs_vel);

      range.x = pos.x - obs_pos.x;
      range.y = pos.y - obs_pos.y;
      range.z = pos.z - obs_pos.z;

      # Save these values globally for calculating squint angles later...

      rx=range.x;
      ry=range.y;
      rz=range.z;

      rgvel.x = vel.x - obs_vel.x;
      rgvel.y = vel.y - obs_vel.y;
      rgvel.z = vel.z - obs_vel.z;

      range = RPredict::SGPMath.magnitude(range);

      sin_lat=Math::sin(geodetic.lat);
      cos_lat=Math::cos(geodetic.lat);
      sin_theta=Math::sin(geodetic.theta);
      cos_theta=Math::cos(geodetic.theta);
      top_s=sin_lat*cos_theta*range.x+sin_lat*sin_theta*range.y-cos_lat*range.z;
      top_e=-sin_theta*range.x+cos_theta*range.y;
      top_z=cos_lat*cos_theta*range.x+cos_lat*sin_theta*range.y+sin_lat*range.z;
      azim=atan(-top_e/top_s); # Azimuth

      if (top_s>0.0)
        azim=azim+pi;

      if (azim<0.0)
        azim=azim+twopi;

      el=Math::asin(top_z/range.w);
      obs_set.x=azim;  # Azimuth (radians)
      obs_set.y=el;    # Elevation (radians)
      obs_set.z=range.w; # Range (kilometers)

      # Range Rate (kilometers/second)
      # ????????
      obs_set.w=vdot(range,rgvel)/range.w;

      # Corrections for atmospheric refraction
      # Reference:  Astronomical Algorithms by Jean Meeus, pp. 101-104
      # Correction is meaningless when apparent elevation is below horizon

      #** The following adjustment for atmospheric refraction is bypassed **

      # obs_set.y=obs_set.y+Radians((1.02/tan(Radians(Degrees(el)+10.3/(Degrees(el)+5.11))))/60);

      obs_set.y=el;

      #*** End bypass ***

      if (obs_set.y>=0.0)
        RPredict::Norad::setFlag(VISIBLE_FLAG);
      else
        obs_set.y=el;  # Reset to true elevation
        RPredict::Norad::clearFlag(VISIBLE_FLAG);
      end
      obs_set
    end

  end

end
