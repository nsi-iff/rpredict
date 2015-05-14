require 'date'

module RPredict
  module DateUtil
    extend self

    #Deprecate
    def currentDaynum()
      #Interno UTC
      #Hour UTC
      (DateTime.parse(Time.now.utc.to_s).strftime('%Q').to_i - 315446400000) / 86400000.0
    end

    #Deprecate
    def daynum2Date(daynum)
      DateTime.strptime(((daynum * 86400000.0 + 315446400000)/1000.0).to_s, '%s')
    end

    def currentDayTime()
       julianday_DateTime(DateTime.parse(Time.now.utc.to_s))
    end

    def day(dateTime)
       julianday_DateTime(DateTime.parse(Time.parse(dateTime).utc.to_s))
    end

    def dayNum(month, day, year)

      if (month < 3)
        year--
        month += 12
      end

      if (year <= 50)
        year += 100
      end

      dayn = ((365.25 * (year - 80.0)).floor - (19.0 + year / 100.0).floor + (4.75 + year / 400.0).floor - 16.0)
      dayn += day + 30 * month + (0.6 * month - 0.3).floor

    end

    def doy(yr, mo, dy)

      days= [31,28,31,30,31,30,31,31,30,31,30,31]

      day = 0
      for i in 0...mo-1 do
        day += days[i]
      end

      day = day + dy

      # Leap year correction
      if((yr%4 == 0) && ((yr%100 != 0) || (yr%400 == 0)) && (mo>2))
        day+=1
      end
      day
    end  #Function DOY



    def delta_ET(year)

      delta_et = 0.0

      delta_et = 26.465 + 0.747622 * (year - 1950) + 1.886913 * Math::sin(RPredict::Norad::TWOPI * (year - 1975) / 33)
      delta_et
    end

    def julianday(year, mon, day, hr, minute, sec)
      julianday_DateTime(DateTime.parse(Time.new(year, mon, day, hr, minute, sec).utc.to_s))
    end

    def julianday_DateTime(dateTime)
      dateTime.ajd.to_f

    end #Function Julian_Date

    def invjulianday(jd)

      # - - - - - - - - - - - - - - -find year and days of the year - - - - - - - - - - - - - - -* /
      temp    = jd - 2415019.5
      tu      = temp / 365.25
      year    = 1900 + (tu).floor
      leapyrs = ((year - 1901) * 0.25).floor

      #optional nudge by 8.64x10 - 7 sec to get even outputs

      days = temp - ((year - 1900) * 365.0 + leapyrs) + 0.00000000001

      #* - - - - - - - - - - - -check for case of beginning of a year - - - - - - - - - - -* /
      if (days < 1.0)
          year    = year - 1
          leapyrs = ((year - 1901) * 0.25).floor
          days    = temp - ((year - 1900) * 365.0 + leapyrs)
      end

      #- - - - - - - - - - - - - - - - -find remaing data - - - - - - - - - - - - - - - - - - - - - - - - -* /

      mon, day, hr, minute, sec = days2mdhms(year, days)

      sec = sec - 0.00000086400

      return year, mon, day, hr, minute, sec
    end

    def invjulianday_DateTime(jd)
      year, mon, day, hr, minute, sec = RPredict::DateUtil.invjulianday(jd)
      DateTime.parse(Time.parse(DateTime.new(year, mon, day, hr, minute, sec).to_s).to_s)

    end

    def days2mdhms(year, days)

      lmonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

        dayofyr = days.floor
      #- - - - - - - - - - - - - - - - -find month and day of month - - - - - - - - - - - - - - - -* /

      if ((year % 4) == 0)
          lmonth[1] = 29
      end

      i = 1
      inttemp = 0
      while ((dayofyr > inttemp + lmonth[i - 1]) and (i < 12))
          inttemp = inttemp + lmonth[i - 1]
          i+=1
      end

      mon = i.floor
      day = dayofyr - inttemp

      # - - - - - - - - - - - - - - - - -find hours minutes and seconds - - - - - - - - - - - - -* /
      temp = (days - dayofyr) * 24.0
      hr = temp.floor
      temp = (temp - hr) * 60.0
      minute = temp.floor
      sec = (temp - minute) * 60.0
      return mon,day,hr,minute,sec
    end


    ### julian_Date_of_Year+day <=> days2mdhms+julianDay
    def julian_Date_of_Year(year)

      # The function Julian_Date_of_Year calculates the Julian Date
      # of Day 0.0 of {year}. This function is used to calculate the
      # Julian Date of any date by using Julian_Date_of_Year, DOY,
      # and Fraction_of_Day. */

      # Astronomical Formulae for Calculators, Jean Meeus,
      # pages 23-25. Calculate Julian Date of 0.0 Jan year

      year = year-1
      i    = year/100
      a    = i
      i    = a/4
      b    = 2-a+i
      i    = (365.25*year).to_i
      i    += (30.6001*14).to_i
      i+1720994.5+b

    end

    def julian_Date_of_Epoch(epoch)

      # The function Julian_Date_of_Epoch returns the Julian Date of
      # an epoch specified in the format used in the NORAD two-line
      # element sets. It has been modified to support dates beyond
      # the year 1999 assuming that two-digit years in the range 00-56
      # correspond to 2000-2056. Until the two-line element set format
      # is changed, it is only valid for dates through 2056 December 31.

      year = epoch[0..1].to_i
      day  = epoch[2..-1].to_f
      #p "year = #{year}  day #{day}"
      #year = (epoch.to_f * 1E-3).to_i
      #day = ((epoch.to_f * 1E-3) - year) * 1E3
      #p "year = #{year}  day #{day}"

      julian_Date_of_Year(year < 57 ? year+2000:year+1900) + day

    end

    #Fraction_of_Day calculates the fraction of */
    # a day passed at the specified input time.  */
    def fraction_of_Day(hr,mi,se)

      ( (hr + (mi + se/60.0)/60.0)/24.0 )
    end #Function Fraction_of_Day*/



     def thetaG_JD(jd)

      # Reference:  The 1992 Astronomical Almanac, page B6.

      ut = RPredict::SGPMath.frac(jd+0.5)
      jd = jd-ut
      tu = (jd-2451545.0)/36525
      gmst =24110.54841+tu*(8640184.812866+tu*(0.093104-tu*6.2E-6))
      gmst = RPredict::SGPMath.modulus(gmst+RPredict::Norad::SECDAY*
             RPredict::Norad::OMEGA_E*ut,RPredict::Norad::SECDAY)

      RPredict::Norad::TWOPI*gmst/RPredict::Norad::SECDAY
    end

    def thetaG(epoch, deep_arg)

      # The function ThetaG calculates the Greenwich Mean Sidereal Time
      # for an epoch specified in the format used in the NORAD two-line
      # element sets. It has now been adapted for dates beyond the year
      # 1999, as described above. The function ThetaG_JD provides the
      # same calculation except that it is based on an input in the
      # form of a Julian Date. */

      # Reference:  The 1992 Astronomical Almanac, page B6.


      year = (epoch * 1E-3).to_i
      day  = ((epoch * 1E-3) - year) * 1E3

      if (year < 57)
        year += 2000
      else
        year += 1900
      end

      ut   = (day - day.to_i)
      day  = day.to_i
      jd   = julian_Date_of_Year(year) + day
      tu   = (jd - 2451545.0) / 36525
      gmst = 24110.54841 + tu * (8640184.812866 + tu * (0.093104 - tu * 6.2E-6))
      gmst = (gmst + RPredict::Norad::SECDAY * omega_E * ut)%RPredict::Norad::SECDAY
      ##LG thetaG = twopi * gmst / RPredict::Norad::SECDAY

      deep_arg.ds50 = jd - 2433281.5 + ut

      _thetaG = RPredict::SGPMath.fMod2p(6.3003880987 * deep_arg.ds50 + 1.72944494)

      return  _thetaG,deep_arg

    end

  end
end
