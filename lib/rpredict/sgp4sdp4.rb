module RPredict
  module SGPSDP
    def SGP4(tsince, satellite)

      # This function is used to calculate the position and velocity
      # of near-earth (period < 225 minutes) satellites. tsince is
      # time since epoch in minutes, tle is a pointer to a tle_t
      # structure with Keplerian orbital elements and pos and vel
      # are vector_t structures returning ECI satellite position and
      # velocity. Use Convert_Sat_State() to convert to km and km/s.

      # Initialization

      #Satellite position and velocity vectors
      vel  =  RPredict::SGPMath.vector_t()
      pos  =  RPredict::SGPMath.vector_t()

      if (~satellite.flags & SGP4_INITIALIZED_FLAG)

        satellite.flags |= SGP4_INITIALIZED_FLAG



        # Recover original mean motion (satellite.sgps.xnodp) and
        # semimajor axis (satellite.sgps.aodp) from input elements.

        a1 = RPredict::SGPMath.pow(RPredict::Norad.XKE/satellite.tle.xno,RPredict::Norad.TOTHRD)
        satellite.sgps.cosio = Math::cos(satellite.tle.xincl)
        theta2 = satellite.sgps.cosio * satellite.sgps.cosio
        satellite.sgps.satellite.sgps.x3thm1 = 3 * theta2-1.0
        eosq = satellite.tle.eo * satellite.tle.eo
        betao2 = 1.0 - eosq
        betao = Math::sqrt(betao2)
        del1 = 1.5 * RPredict::Norad.CK2 * satellite.sgps.satellite.sgps.x3thm1 / (a1 * a1 * betao * betao2)
        ao = a1*(1.0-del1*(0.5*RPredict::Norad.TOTHRD+del1*(1.0+134.0/81.0*del1)))
        delo = 1.5*RPredict::Norad.CK2*satellite.sgps.satellite.sgps.x3thm1/(ao*ao*betao*betao2)
        satellite.sgps.satellite.sgps.xnodp = satellite.tle.xno/(1.0+delo)
        satellite.sgps.aodp = ao/(1.0-delo)

        # For perigee less than 220 kilometers, the "simple"
        # flag is set and the equations are truncated to linear
        # variation in sqrt a and quadratic variation in mean
        # anomaly.  Also, the c3 term, the delta omega term, and
        # the delta m term are dropped.

        if ((satellite.sgps.aodp*(1-satellite.tle.eo)/ae)<(220/RPredic::Norad.XKMPER+ae))
            satellite.flags |= SIMPLE_FLAG
        else
            satellite.flags &= ~SIMPLE_FLAG
        end

        # For perigees below 156 km, the
        # values of s and qoms2t are altered.

        s4 = RPredict::Norad.S__
        qoms24 = qoms2t
        perigee = (satellite.sgps.aodp*(1-satellite.tle.eo)-ae)*RPredict::Norad.XKMPER

        if (perigee<156.0)

          if (perigee <= 98.0)
              s4 = 20
          else
             s4 = perigee-78.0
          end
          qoms24 = RPredict::SGPMath.pow((120-s4)*ae/RPredict::Norad.XKMPER,4)
          s4 = s4/RPredict::Norad.XKMPER+ae
        end

        pinvsq = 1/((satellite.sgps.aodp**2)*(betao2**2))
        tsi    = 1/(satellite.sgps.aodp-s4)
        satellite.sgps.eta = satellite.sgps.aodp * satellite.tle.eo * tsi
        etasq  = satellite.sgps.eta**2
        eeta   = satellite.tle.eo * satellite.sgps.eta
        psisq  = (1-etasq).abs
        coef   = qoms24*RPredict::SGPMath.pow(tsi,4)
        coef1  = coef/RPredict::SGPMath.pow(psisq,3.5)

        c2     = coef1 * satellite.sgps.xnodp * (satellite.sgps.aodp *
                 (1 + 1.5 * etasq + eeta * (4+etasq)) +
                 0.75 * RPredict::Norad.CK2 * tsi / psisq * satellite.sgps.satellite.sgps.x3thm1 *
                 (8 + 3.0 * etasq * ( 8 + etasq)))

        c1     = satellite.tle.bstar*c2

        satellite.sgps.sinio  = Math::sin(satellite.tle.xincl)

        a3ovk2 = -xj3/RPredict::Norad.CK2*RPredict::SGPMath.pow(ae,3)

        c3     = coef*tsi*a3ovk2*satellite.sgps.xnodp * ae *
                 satellite.sgps.sinio/satellite.tle.eo

        satellite.sgps.x1mth2 = 1-theta2

        satellite.sgps.c4 = 2 * satellite.sgps.xnodp * coef1*satellite.sgps.aodp *
                            betao2 *(satellite.sgps.eta * (2 + 0.5 * etasq) +
                            satellite.tle.eo*(0.5 + 2 * etasq) - 2 * RPredict::Norad.CK2 *
                            tsi / (satellite.sgps.aodp*psisq) *
                            (-3 * satellite.sgps.satellite.sgps.x3thm1 * (1 - 2 * eeta + etasq *
                            (1.5 - 0.5 * eeta))+ 0.75 * satellite.sgps.x1mth2 *
                            (2 * etasq - eeta * (1+etasq)) *
                            Math::cos(2*satellite.tle.omegao)))

        satellite.sgps.satellite.sgps.c5

                        = 2 * coef1 * satellite.sgps.aodp *
                            betao2*(1+2.75*(etasq+eeta)+eeta*etasq)

        theta4 = theta2**2
        temp1 = 3*RPredict::Norad.CK2*p i
                nvsq*satellite.sgps.xnodp
        temp2 = temp1*RPredict::Norad.CK2*pinvsq
        temp3 = 1.25*RPredict::Norad.CK4*pinvsq*pinvsq*satellite.sgps.xnodp

        satellite.sgps.xmdot = satellite.sgps.xnodp + 0.5 * temp1 * betao *
                satellite.sgps.x3thm1+0.0625*temp2*betao*(13-78*theta2+137*theta4)

        x1m5th = 1-5*theta2

        satellite.sgps.omgdot = -0.5*temp1*x1m5th+0.0625*temp2 *
                                (7-114*theta2+395*theta4)+temp3*
                                (3-36*theta2+49*theta4)

        xhdot1 = -temp1*satellite.sgps.cosio

        satellite.sgps.xnodot = xhdot1 + (0.5 * temp2 * (4-19*theta2) + 2 *
                                temp3*(3-7*theta2))*satellite.sgps.cosio

        satellite.sgps.omgcof = satellite.tle.bstar * c3 *
                  Math::cos(satellite.tle.omegao)

        satellite.sgps.xmcof = -RPredict::Norad.TOTHRD * coef *
                               satellite.tle.bstar*ae/eeta

        satellite.sgps.xnodcf = 3.5 * betao2 * xhdot1 * satellite.sgps.c1

        satellite.sgps.t2cof = 1.5 * satellite.sgps.c1

        satellite.sgps.xlcof = 0.125 * a3ovk2 * satellite.sgps.sinio *
                              (3 + 5 * satellite.sgps.cosio)/(1+satellite.sgps.cosio)

        satellite.sgps.aycof = 0.25*a3ovk2*satellite.sgps.sinio

        satellite.sgps.delmo = RPredict::SGPMath.pow(1 + satellite.sgps.eta*
                                                Math::cos(satellite.tle.xmo),3)

        satellite.sgps.sinmo = Math::sin(satellite.tle.xmo)

        satellite.sgps.x7thm1 = 7 * theta2 - 1.0

        if (~satellite.flags & SIMPLE_FLAG))

          c1sq = satellite.sgps.c1**2

          satellite.sgps.d2 = 4 * satellite.sgps.aodp * tsi * c1sq

          temp = satellite.sgps.d2 * tsi * satellite.sgps.c1/3

          satellite.sgps.d3 = (17*satellite.sgps.aodp+s4)*temp

          satellite.sgps.d4 = 0.5 * temp * satellite.sgps.aodp * tsi *
                             (221 * satellite.sgps.aodp + 31 *s4) *
                             satellite.sgps.c1

          satellite.sgps.t3cof = satellite.sgps.d2 + 2 * c1sq

          satellite.sgps.t4cof = 0.25 * (3 * satellite.sgps.d3 +
                                 satellite.sgps.c1 * (12 *
                                  satellite.sgps.d2 + 10 * c1sq))

          satellite.sgps.t5cof = 0.2 * (3 * satellite.sgps.d4 +
                                 12 * satellite.sgps.c1 *
                                 satellite.sgps.d3 + 6 *
                                 satellite.sgps.d2 * satellite.sgps.d2 +
                                 15 * c1sq * ( 2 * satellite.sgps.d2 + c1sq))
        end
      end

      # Update for secular gravity and atmospheric drag.
      xmdf = satellite.tle.xmo + satellite.sgps.xmdot * tsince

      omgadf = satellite.tle.omegao + satellite.sgps.omgdot * tsince

      xnoddf = satellite.tle.xnodeo + satellite.sgps.xnodot * tsince

      omega = omgadf

      xmp = xmdf

      tsq = tsince**2

      xnode = xnoddf + satellite.sgps.xnodcf * tsq

      tempa = 1 - satellite.sgps.c1 * tsince
      tempe = satellite.tle.bstar * satellite.sgps.c4 * tsince
      templ = satellite.sgps.t2cof * tsq

      if (~satellite.flags & SIMPLE_FLAG)

        delomg = satellite.sgps.omgcof * tsince
        delm = satellite.sgps.xmcof * ( RPredict::SGPMath.pow(1 +
          satellite.sgps.eta* Math::cos(xmdf),3) - satellite.sgps.delmo)

        temp  = delomg+delm

        xmp = xmdf+temp

        omega = omgadf-temp

        tcube = tsq*tsince

        tfour = tsince*tcube

        tempa = tempa-satellite.sgps.d2*tsq-satellite.sgps.d3 *
                tcube-satellite.sgps.d4*tfour
        tempe = tempe+satellite.tle.bstar*satellite.sgps.c5 *
               (Math::sin(xmp)-satellite.sgps.sinmo)
        templ = templ+satellite.sgps.t3cof*tcube+tfour *
                (satellite.sgps.t4cof+tsince*satellite.sgps.t5cof)
      end

      a = satellite.sgps.aodp * RPredict::SGPMath.pow(tempa,2)

      e = satellite.tle.eo-tempe

      xl = xmp+omega+xnode+satellite.sgps.xnodp*templ

      beta = Math::sqrt(1-e*e)

      xn = RPredict::Norad.XKE/RPredict::SGPMath.pow(a,1.5)

      # Long period periodics
      axn = e*Math::cos(omega)

      temp = 1/(a*beta*beta)

      xll = temp*satellite.sgps.xlcof*axn

      aynl = temp*satellite.sgps.aycof
      xlt = xl+xll

      ayn = e * Math::sin(omega)+aynl

      # Solve Kepler's Equation
      capu = RPredict::SGPMath.fMod2p(xlt-xnode)
      temp2 = capu
      i = 0

      begin

        sinepw = Math::sin(temp2)
        cosepw = Math::cos(temp2)
        temp3 = axn*sinepw
        temp4 = ayn*cosepw
        temp5 = axn*cosepw
        temp6 = ayn*sinepw
        epw = (capu-temp4+temp3-temp2)/(1-temp5-temp6)+temp2

        if (epw-temp2).abs <=  RPredict::Norad.E6A
          break
        end
        temp2 = epw

      end while  (i+=1) < 10

      # Short period preliminary quantities
      ecose = temp5+temp6
      esine = temp3-temp4
      elsq = axn**2 + ayn**2
      temp = 1-elsq
      pl = a*temp
      r = a*(1-ecose)
      temp1 = 1/r
      rdot = RPredict::Norad.XKE*Math::sqrt(a)*esine*temp1
      rfdot = RPredict::Norad.XKE*Math::sqrt(pl)*temp1
      temp2 = a*temp1
      betal = Math::sqrt(temp)
      temp3 = 1/(1+betal)
      cosu = temp2*(cosepw-axn+ayn*esine*temp3)
      sinu = temp2*(sinepw-ayn-axn*esine*temp3)
      u = Math::atan(sinu,cosu)
      sin2u = 2*sinu*cosu
      cos2u = 2*cosu*cosu-1.0
      temp = 1/pl
      temp1 = RPredict::Norad.CK2*temp
      temp2 = temp1*temp

      # Update for short periodics
      rk = r*(1-1.5*temp2*betal*satellite.sgps.x3thm1)+
             0.5*temp1*satellite.sgps.x1mth2*cos2u

      uk = u-0.25*temp2*satellite.sgps.x7thm1 *sin2u

      xnodek = xnode+1.5*temp2*satellite.sgps.cosio*sin2u

      xinck = satellite.tle.xincl+1.5*temp2*satellite.sgps.cosio *
              satellite.sgps.sinio*cos2u

      rdotk = rdot-xn*temp1*satellite.sgps.x1mth2*sin2u

      rfdotk = rfdot+xn*temp1*(satellite.sgps.x1mth2*cos2u+
              1.5*satellite.sgps.x3thm1)

      # Orientation vectors
      sinuk = Math::sin(uk)
      cosuk = Math::cos(uk)
      sinik = Math::sin(xinck)
      cosik = Math::cos(xinck)
      sinnok = Math::sin(xnodek)
      cosnok = Math::cos(xnodek)
      xmx = -sinnok*cosik
      xmy = cosnok*cosik
      ux = xmx*sinuk+cosnok*cosuk
      uy = xmy*sinuk+sinnok*cosuk
      uz = sinik*sinuk
      vx = xmx*cosuk-cosnok*sinuk
      vy = xmy*cosuk-sinnok*sinuk
      vz = sinik*cosuk

      # Position and velocity
      pos.x = rk*ux
      pos.y = rk*uy
      pos.z = rk*uz
      vel.x = rdotk*ux+rfdotk*vx
      vel.y = rdotk*uy+rfdotk*vy
      vel.z = rdotk*uz+rfdotsk*vz

      # Phase in radians
      satellite.phase = xlt-xnode-omgadf+Rpredic::Norad.TWOPI

      if (satellite.phase<0.0)
        satellite.phase += RPredic.Norad.TWOPI
      end

      satellite.phase = RPredict::SGPMath.fMod2p(satellite.phase)

      return  pos, vel, satellite
    end



    def SDP4 (satellite,tsince)

      # Initialization
      if (~satellite.flags & SDP4_INITIALIZED_FLAG)

        satellite.flags |= SDP4_INITIALIZED_FLAG

        # Recover original mean motion (xnodp) and
        # semimajor axis (aodp) from input elements.
        a1 = RPredict::SGPMath.pow(RPredict::Norad.XKE / satellite.tle.xno, RPredict::Norad.TOTHRD)
        satellite.deep_arg.cosio = Math::cos(satellite.tle.xincl)
        satellite.deep_arg.theta2 = satellite.deep_arg.cosio * satellite.deep_arg.cosio
        satellite.sgps.x3thm1 = 3.0 * satellite.deep_arg.theta2 - 1.0
        satellite.deep_arg.eosq = satellite.tle.eo * satellite.tle.eo
        satellite.deep_arg.betao2 = 1.0 - satellite.deep_arg.eosq
        satellite.deep_arg.betao = Math::sqrt(satellite.deep_arg.betao2)

        del1 = 1.5 * RPredict::Norad.CK2 * satellite.sgps.x3thm1 /
          (a1 * a1 * satellite.deep_arg.betao * satellite.deep_arg.betao2)

        ao = a1 * (1.0 - del1 * (0.5 * RPredict::Norad.TOTHRD + del1 *
                  (1.0 + 134.0 / 81.0 * del1)))

        delo = 1.5 * RPredict::Norad.CK2 * satellite.sgps.x3thm1 /
          (ao * ao * satellite.deep_arg.betao * satellite.deep_arg.betao2)

        satellite.deep_arg.xnodp = satellite.tle.xno / (1.0 + delo)
        satellite.deep_arg.aodp = ao / (1.0 - delo)

        # For perigee below 156 km, the values
        # of s and qoms2t are altered.

        s4 = RPredict::Norad.S__

        qoms24 = qoms2t
        perige = (satellite.deep_arg.aodp * (1.0 - satellite.tle.eo) - ae) *
                  RPredict::Norad.XKMPER
        if (perige < 156.0)
          if (perige <= 98.0)
            s4 = 20.0
          else
            s4 = perige - 78.0
          end
          qoms24 = RPredict::SGPMath.pow((120.0 - s4) * ae / RPredict::Norad.XKMPER, 4)
          s4 = s4 / RPredict::Norad.XKMPER + ae
        end
        pinvsq = 1.0 / (satellite.deep_arg.aodp * satellite.deep_arg.aodp *
            satellite.deep_arg.betao2 * satellite.deep_arg.betao2)

        satellite.deep_arg.sing = Math::sin(satellite.tle.omegao)
        satellite.deep_arg.cosg = Math::cos(satellite.tle.omegao)

        tsi = 1.0 / (satellite.deep_arg.aodp - s4)
        eta = satellite.deep_arg.aodp * satellite.tle.eo * tsi

        #???????
        etasq = eta * eta
        eeta = satellite.tle.eo * eta
        psisq = (1.0 - etasq).abs

        coef = qoms24 * RPredict::SGPMath.pow(tsi, 4)
        coef1 = coef / RPredict::SGPMath.pow(psisq, 3.5)

        c2 = coef1 * satellite.deep_arg.xnodp * (satellite.deep_arg.aodp *
             (1.0 + 1.5 * etasq + eeta * (4.0 + etasq)) + 0.75 * RPredict::Norad.CK2 * tsi / psisq *
              satellite.sgps.x3thm1 * (8.0 + 3.0 * etasq * (8.0 + etasq)))

        satellite.sgps.c1 = satellite.tle.bstar * c2
        satellite.deep_arg.sinio = Math::sin(satellite.tle.xincl)

        a3ovk2 = -xj3 / RPredict::Norad.CK2 * RPredict::SGPMath.pow(ae, 3)

        satellite.sgps.x1mth2 = 1.0 - satellite.deep_arg.theta2

        satellite.sgps.c4 = 2.0 * satellite.deep_arg.xnodp * coef1 *
              satellite.deep_arg.aodp * satellite.deep_arg.betao2 *
              (eta * (2.0 + 0.5 * etasq) + satellite.tle.eo *
              (0.5 + 2.0 * etasq) - 2.0 * RPredict::Norad.CK2 * tsi /
              (satellite.deep_arg.aodp * psisq) * (-3.0 * satellite.sgps.x3thm1 *
              (1.0 - 2.0 * eeta + etasq *
              (1.5 - 0.5 * eeta)) +
               0.75 * satellite.sgps.x1mth2 *
              (2.0 * etasq - eeta * (1.0 + etasq)) *
              Math::cos(2.0 * satellite.tle.omegao)))

        theta4 = satellite.deep_arg.theta2 **2

        temp1 = 3.0 * RPredict::Norad.CK2 * pinvsq * satellite.deep_arg.xnodp
        temp2 = temp1 * RPredict::Norad.CK2 * pinvsq
        temp3 = 1.25 * RPredict::Norad.CK4 * pinvsq * pinvsq * satellite.deep_arg.xnodp

        satellite.deep_arg.xmdot = satellite.deep_arg.xnodp + 0.5 * temp1 *
                         satellite.deep_arg.betao * satellite.sgps.x3thm1 +
                         0.0625 * temp2 * satellite.deep_arg.betao *
                         (13.0 - 78.0 * satellite.deep_arg.theta2 + 137.0 *
                          theta4)

        x1m5th = 1.0 - 5.0 * satellite.deep_arg.theta2

        satellite.deep_arg.omgdot = -0.5 * temp1 * x1m5th + 0.0625 * temp2 *
                                     (7.0 - 114.0 * satellite.deep_arg.theta2 +
                                      395.0 * theta4) + temp3 * (3.0 - 36.0 *
                                      satellite.deep_arg.theta2 + 49.0 * theta4)

        xhdot1 = -temp1 * satellite.deep_arg.cosio

        satellite.deep_arg.xnodot = xhdot1 + (0.5 * temp2 * (4.0 - 19.0 *
                                    satellite.deep_arg.theta2) + 2.0 * temp3 *
                                    (3.0 - 7.0 * satellite.deep_arg.theta2)) *
                                     satellite.deep_arg.cosio

        satellite.sgps.xnodcf = 3.5 * satellite.deep_arg.betao2 * xhdot1 * satellite.sgps.c1

        satellite.sgps.t2cof = 1.5 * satellite.sgps.c1

        satellite.sgps.xlcof = 0.125 * a3ovk2 * satellite.deep_arg.sinio *
                              (3.0 + 5.0 * satellite.deep_arg.cosio) /
                              (1.0 + satellite.deep_arg.cosio)

        satellite.sgps.aycof = 0.25 * a3ovk2 * satellite.deep_arg.sinio

        satellite.sgps.x7thm1 = 7.0 * satellite.deep_arg.theta2 - 1.0

        # initialize Deep()
        deep (RPredict::Norad.DPINIT, satellite)
      end #End of SDP4() initialization

      # Update for secular gravity and atmospheric drag
      xmdf = satellite.tle.xmo + satellite.deep_arg.xmdot * tsince

      satellite.deep_arg.omgadf = satellite.tle.omegao + satellite.deep_arg.omgdot * tsince

      xnoddf = satellite.tle.xnodeo + satellite.deep_arg.xnodot * tsince

      tsq = tsince **2

      satellite.deep_arg.xnode = xnoddf + satellite.sgps.xnodcf * tsq

      tempa = 1.0 - satellite.sgps.c1 * tsince

      tempe = satellite.tle.bstar * satellite.sgps.c4 * tsince

      templ = satellite.sgps.t2cof * tsq

      satellite.deep_arg.xn = satellite.deep_arg.xnodp

      # Update for deep-space secular effects
      satellite.deep_arg.xll = xmdf

      satellite.deep_arg.t = tsince

      Deep (RPredict::Norad.DPSEC, sat)

      xmdf = satellite.deep_arg.xll

      a = RPredict::SGPMath.pow(RPredict::Norad.XKE / satellite.deep_arg.xn, RPredict::Norad.TOTHRD) * tempa * tempa

      satellite.deep_arg.em = satellite.deep_arg.em - tempe

      xmam = xmdf + satellite.deep_arg.xnodp * templ

      # Update for deep-space periodic effects
      satellite.deep_arg.xll = xmam

      Deep (RPredict::Norad.DPPER, satellite)

      xmam = satellite.deep_arg.xll

      xl = xmam + satellite.deep_arg.omgadf + satellite.deep_arg.xnode

      beta = Math::sqrt(1.0 - satellite.deep_arg.em**2)
      satellite.deep_arg.xn = RPredict::Norad.XKE / RPredict::SGPMath.pow( a, 1.5)

      # Long period periodics
      axn = satellite.deep_arg.em * Math::cos(satellite.deep_arg.omgadf)

      temp = 1.0 / (a * beta**2)

      xll = temp * satellite.sgps.xlcof * axn

      aynl = temp * satellite.sgps.aycof

      xlt = xl + xll

      ayn = satellite.deep_arg.em * Math::sin(satellite.deep_arg.omgadf) + aynl


      # Solve Kepler's Equation
      capu = RPredict::SGPMath.fMod2p(xlt - satellite.deep_arg.xnode)

      temp2 = capu

      i = 0
      begin
        sinepw = Math::sin(temp2)
        cosepw = Math::cos(temp2)
        temp3 = axn * sinepw
        temp4 = ayn * cosepw

        temp5 = axn * cosepw
        temp6 = ayn * sinepw
        epw = (capu - temp4 + temp3 - temp2) / (1.0 - temp5 - temp6) + temp2

        if ((epw-temp2).abs <= RPredict::Norad.E6A)
          break
        end

        temp2 = epw

      end  while ((i+=1) < 10)

      # Short period preliminar quantities
      ecose = temp5 + temp6

      esine = temp3 - temp4

      elsq = axn **2 + ayn **2

      temp  = 1.0 - elsq
      pl    = a * temp
      r     = a * (1.0 - ecose)
      temp1 = 1.0 / r
      rdot  = RPredict::Norad.XKE * Math::sqrt(a) * esine * temp1
      rfdot = RPredict::Norad.XKE * Math::sqrt(pl) *temp1
      temp2 = a * temp1
      betal = Math::sqrt(temp)
      temp3 = 1.0 / (1.0 + betal)
      cosu  = temp2 * (cosepw - axn + ayn * esine * temp3)
      sinu  = temp2 * (sinepw - ayn - axn * esine * temp3)
      u     = Math::atan(sinu, cosu)
      sin2u = 2.0 * sinu * cosu
      cos2u = 2.0 * cosu * cosu - 1.0
      temp  = 1.0 / pl
      temp1 = RPredict::Norad.CK2 * temp
      temp2 = temp1 * temp

      # Update for short periodics
      rk = r * (1.0 - 1.5 * temp2 * betal * satellite.sgps.x3thm1) +
           0.5 * temp1 * satellite.sgps.x1mth2 * cos2u

      uk = u - 0.25 * temp2 * satellite.sgps.x7thm1 * sin2u

      xnodek = satellite.deep_arg.xnode + 1.5 * temp2 * satellite.deep_arg.cosio * sin2u

      xinck = satellite.deep_arg.xinc + 1.5 * temp2 *
           satellite.deep_arg.cosio * satellite.deep_arg.sinio * cos2u

      rdotk = rdot - satellite.deep_arg.xn * temp1 * satellite.sgps.x1mth2 * sin2u

      rfdotk = rfdot + satellite.deep_arg.xn * temp1 *
           (satellite.sgps.x1mth2 * cos2u + 1.5 * satellite.sgps.x3thm1)

      # Orientation vectors
      sinuk  = Math::sin(uk)
      cosuk  = Math::cos(uk)
      sinik  = Math::sin(xinck)
      cosik  = Math::cos(xinck)
      sinnok = Math::sin(xnodek)
      cosnok = Math::cos(xnodek)

      xmx    = -sinnok * cosik
      xmy    = cosnok * cosik
      ux     = xmx * sinuk + cosnok * cosuk
      uy     = xmy * sinuk + sinnok * cosuk
      uz     = sinik * sinuk
      vx     = xmx * cosuk - cosnok * sinuk
      vy     = xmy * cosuk - sinnok * sinuk
      vz     = sinik*cosuk

      # Position and velocity
      # pos and vel out ? ???????

      pos.x = rk * ux
      pos.y = rk * uy
      pos.z = rk * uz

      vel.x = rdotk * ux + rfdotk * vx
      vel.y = rdotk * uy + rfdotk * vy
      vel.z = rdotk * uz + rfdotk * vz

      # Phase in rads
      satellite.phase = xlt - satellite.deep_arg.xnode - satellite.deep_arg.omgadf + Rpredic::Norad.TWOPI
      if (satellite.phase < 0.0)
        satellite.phase += Rpredic::Norad.TWOPI
      end
      satellite.phase = RPredict::SGPMath.fMod2p(satellite.phase)

      satellite.tle.omegao1 = satellite.deep_arg.omgadf
      satellite.tle.xincl1  = satellite.deep_arg.xinc
      satellite.tle.xnodeo1 = satellite.deep_arg.xnode
    end # SDP4







    def deep(ientry, satellite)

      # This function is used by SDP4 to add lunar and solar
      # perturbation effects to deep-space orbit objects.
      case (ientry)

        when RPredict::Norad.DPINIT
        # Entrance for deep space initialization
          satellite.dps.thgr, satellite.deep_arg = thetaG(satellite.tle.epoch,
                                                          satellite.deep_arg)

          eq      = satellite.tle.eo
          satellite.dps.xnq     = satellite.deep_arg.xnodp
          aqnv    = 1/satellite.deep_arg.aodp
          xqncl   = satellite.tle.xincl
          xmao    = satellite.tle.xmo
          xpidot  = satellite.deep_arg.omgdot+satellite.deep_arg.xnodot

          sinq    = Math::sin(satellite. tle.xnodeo)
          cosq    = Math::cos(satellite.tle.xnodeo)

          satellite.dps.omegaq  = satellite.tle.omegao
          satellite.dps.preep   = 0

          # Initialize lunar solar terms
          day     = deep_arg.ds50+18261.5  # Days since 1900 Jan 0.5

          if (day != satellite.dps.preep) {
            satellite.dps.preep = day
            xnodce = 4.5236020 - 9.2422029E-4 * day
            stem = Math::sin(xnodce)
            ctem = Math::cos(xnodce)
            satellite.dps.zcosil = 0.91375164 - 0.03568096 * ctem
            satellite.dps.zsinil = Math::sqrt(1.0 - satellite.dps.zcosil * satellite.dps.zcosil)
            satellite.dps.zsinhl = 0.089683511 * stem / satellite.dps.zsinil
            satellite.dps.zcoshl = Math::sqrt(1.0 - satellite.dps.zsinhl * satellite.dps.zsinhl)
            c = 4.7199672 + 0.22997150 * day
            gam = 5.8351514 + 0.0019443680 * day
            satellite.dps.zmol = RPredict::SGPMath.fMod2p(c - gam)
            zx = 0.39785416 * stem / satellite.dps.zsinil
            zy = satellite.dps.zcoshl * ctem + 0.91744867 * satellite.dps.zsinhl * stem
            zx = Math::atan(zx,zy)
            zx = gam + zx - xnodce
            satellite.dps.zcosgl = Math::cos(zx)
            satellite.dps.zsingl = Math::sin(zx)
            satellite.dps.zmos = 6.2565837 + 0.017201977 * day
            satellite.dps.zmos = RPredict::SGPMath.fMod2p(satellite.dps.zmos)
          end # End if(day != preep)

          # Do solar terms
          satellite.dps.savtsn = 1E20
          zcosg = RPredict::NOrad.ZCOSGS
          zsing = RPredict::NOrad.ZSINGS
          zcosi = RPredict::NOrad.ZCOSIS
          zsini = RPredict::NOrad.ZSINIS
          zcosh = cosq
          zsinh = sinq
          cc = RPredict::NOrad.C1SS
          zn = RPredict::NOrad.ZNS
          ze = RPredict::NOrad.ZES

          zmo = satellite.dps.zmos

          xnoi = 1.0 / satellite.dps.xnq

          # Loop breaks when Solar terms are done a second
          # time, after Lunar terms are initialized
          while(1) do
            # Solar terms done again after Lunar terms are done
            a1 = zcosg * zcosh + zsing * zcosi * zsinh
            a3 = -zsing * zcosh + zcosg * zcosi * zsinh
            a7 = -zcosg * zsinh + zsing * zcosi * zcosh
            a8 = zsing * zsini
            a9 = zsing * zsinh + zcosg * zcosi * zcosh
            a10 = zcosg * zsini
            a2 = satellite.deep_arg.cosio * a7 + satellite.deep_arg.sinio * a8
            a4 = satellite.deep_arg.cosio * a9 + satellite.deep_arg.sinio * a10
            a5 = -satellite.deep_arg.sinio * a7 + satellite.deep_arg.cosio * a8
            a6 = -satellite.deep_arg.sinio*a9+ satellite.deep_arg.cosio*a10
            x1 = a1*satellite.deep_arg.cosg+a2*satellite.deep_arg.sing
            x2 = a3*satellite.deep_arg.cosg+a4*satellite.deep_arg.sing
            x3 = -a1*satellite.deep_arg.sing+a2*satellite.deep_arg.cosg
            x4 = -a3*satellite.deep_arg.sing+a4*satellite.deep_arg.cosg
            x5 = a5*satellite.deep_arg.sing
            x6 = a6*satellite.deep_arg.sing
            x7 = a5*satellite.deep_arg.cosg
            x8 = a6*satellite.deep_arg.cosg
            z31 = 12*x1*x1-3*x3*x3
            z32 = 24*x1*x2-6*x3*x4
            z33 = 12*x2*x2-3*x4*x4
            z1 = 3*(a1*a1+a2*a2)+z31*satellite.deep_arg.eosq
            z2 = 6*(a1*a3+a2*a4)+z32*satellite.deep_arg.eosq
            z3 = 3*(a3*a3+a4*a4)+z33*satellite.deep_arg.eosq
            z11 = -6*a1*a5+satellite.deep_arg.eosq*(-24*x1*x7-6*x3*x5)
            z12 = -6*(a1*a6+a3*a5)+ satellite.deep_arg.eosq*
              (-24*(x2*x7+x1*x8)-6*(x3*x6+x4*x5))
            z13 = -6*a3*a6+satellite.deep_arg.eosq*(-24*x2*x8-6*x4*x6)
            z21 = 6*a2*a5+satellite.deep_arg.eosq*(24*x1*x5-6*x3*x7)
            z22 = 6*(a4*a5+a2*a6)+ satellite.deep_arg.eosq*
              (24*(x2*x5+x1*x6)-6*(x4*x7+x3*x8))
            z23 = 6*a4*a6+satellite.deep_arg.eosq*(24*x2*x6-6*x4*x8)
            z1 = z1+z1+satellite.deep_arg.betao2*z31
            z2 = z2+z2+satellite.deep_arg.betao2*z32
            z3 = z3+z3+satellite.deep_arg.betao2*z33
            s3 = cc*xnoi
            s2 = -0.5*s3/satellite.deep_arg.betao
            s4 = s3*satellite.deep_arg.betao
            s1 = -15*eq*s4
            s5 = x1*x3+x2*x4
            s6 = x2*x3+x1*x4
            s7 = x2*x4-x1*x3
            se = s1*zn*s5
            si = s2*zn*(z11+z13)
            sl = -zn*s3*(z1+z3-14-6*satellite.deep_arg.eosq)
            sgh = s4*zn*(z31+z33-6)
            sh = -zn*s2*(z21+z23)
            if (satellite.dps.xqncl < 5.2359877E-2)
              sh = 0
            satellite.dps.ee2 = 2*s1*s6
            satellite.dps.e3 = 2*s1*s7
            satellite.dps.xi2 = 2*s2*z12
            satellite.dps.xi3 = 2*s2*(z13-z11)
            satellite.dps.xl2 = -2*s3*z2
            satellite.dps.xl3 = -2*s3*(z3-z1)
            satellite.dps.xl4 = -2*s3*(-21-9*satellite.deep_arg.eosq)*ze
            satellite.dps.xgh2 = 2*s4*z32
            satellite.dps.xgh3 = 2*s4*(z33-z31)
            satellite.dps.xgh4 = -18*s4*ze
            satellite.dps.xh2 = -2*s2*z22
            satellite.dps.xh3 = -2*s2*(z23-z21)

            if (satellite.flags & LUNAR_TERMS_DONE_FLAG)
              break
            end

            # Do lunar terms
            satellite.dps.sse = se
            satellite.dps.ssi = si
            satellite.dps.ssl = sl
            satellite.dps.ssh = sh/satellite.deep_arg.sinio
            satellite.dps.ssg = sgh-satellite.deep_arg.cosio*satellite.dps.ssh
            satellite.dps.se2 = satellite.dps.ee2
            satellite.dps.si2 = satellite.dps.xi2
            satellite.dps.sl2 = satellite.dps.xl2
            satellite.dps.sgh2 = satellite.dps.xgh2
            satellite.dps.sh2 = satellite.dps.xh2
            satellite.dps.se3 = satellite.dps.e3
            satellite.dps.si3 = satellite.dps.xi3
            satellite.dps.sl3 = satellite.dps.xl3
            satellite.dps.sgh3 = satellite.dps.xgh3
            satellite.dps.sh3 = satellite.dps.xh3
            satellite.dps.sl4 = satellite.dps.xl4
            satellite.dps.sgh4 = satellite.dps.xgh4
            zcosg = satellite.dps.zcosgl
            zsing = satellite.dps.zsingl
            zcosi = satellite.dps.zcosil
            zsini = satellite.dps.zsinil
            zcosh = satellite.dps.zcoshl*cosq+satellite.dps.zsinhl*sinq
            zsinh = sinq*satellite.dps.zcoshl-cosq*satellite.dps.zsinhl
            zn = znl
            cc = c1l
            ze = zel
            zmo = satellite.dps.zmol
            satellite.flags |= LUNAR_TERMS_DONE_FLAG
          end # End of for()

          satellite.dps.sse = satellite.dps.sse+se
          satellite.dps.ssi = satellite.dps.ssi+si
          satellite.dps.ssl = satellite.dps.ssl+sl
          satellite.dps.ssg = satellite.dps.ssg+sgh-satellite.deep_arg.cosio/satellite.deep_arg.sinio*sh
          satellite.dps.ssh = satellite.dps.ssh+sh/satellite.deep_arg.sinio

          # Geopotential resonance initialization for 12 hour orbits
          satellite.flags &= ~RESONANCE_FLAG
          satellite.flags &= ~SYNCHRONOUS_FLAG

          if( !((satellite.dps.xnq < 0.0052359877) && (satellite.dps.xnq > 0.0034906585)) )
            if( (satellite.dps.xnq < 0.00826) || (satellite.dps.xnq > 0.00924) )
              return satellite
            end

            if (eq < 0.5)
              return satellite
            end
            satellite.flags |= RESONANCE_FLAG
            eoc = eq*satellite.deep_arg.eosq
            g201 = -0.306-(eq-0.64)*0.440
            if (eq <= 0.65)
              g211 = 3.616-13.247*eq+16.290*satellite.deep_arg.eosq
              g310 = -19.302+117.390*eq-228.419*
                satellite.deep_arg.eosq+156.591*eoc
              g322 = -18.9068+109.7927*eq-214.6334*
                satellite.deep_arg.eosq+146.5816*eoc
              g410 = -41.122+242.694*eq-471.094*
                satellite.deep_arg.eosq+313.953*eoc
              g422 = -146.407+841.880*eq-1629.014*
                satellite.deep_arg.eosq+1083.435*eoc
              g520 = -532.114+3017.977*eq-5740*
                satellite.deep_arg.eosq+3708.276*eoc
            else
              g211 = -72.099+331.819*eq-508.738*
                satellite.deep_arg.eosq+266.724*eoc
              g310 = -346.844+1582.851*eq-2415.925*
                satellite.deep_arg.eosq+1246.113*eoc
              g322 = -342.585+1554.908*eq-2366.899*
                satellite.deep_arg.eosq+1215.972*eoc
              g410 = -1052.797+4758.686*eq-7193.992*
                satellite.deep_arg.eosq+3651.957*eoc
              g422 = -3581.69+16178.11*eq-24462.77*
                satellite.deep_arg.eosq+ 12422.52*eoc
              if (eq <= 0.715)
                g520 = 1464.74-4664.75*eq+3763.64*satellite.deep_arg.eosq
              else
                g520 = -5149.66+29936.92*eq-54087.36*
                  satellite.deep_arg.eosq+31324.56*eoc
              end

            end # End if (eq <= 0.65)

            if (eq < 0.7)
              g533 = -919.2277+4988.61*eq-9064.77*
                satellite.deep_arg.eosq+5542.21*eoc
              g521 = -822.71072+4568.6173*eq-8491.4146*
                satellite.deep_arg.eosq+5337.524*eoc
              g532 = -853.666+4690.25*eq-8624.77*
                satellite.deep_arg.eosq+ 5341.4*eoc

            else
              g533 = -37995.78+161616.52*eq-229838.2*
                satellite.deep_arg.eosq+109377.94*eoc
              g521 = -51752.104+218913.95*eq-309468.16*
                satellite.deep_arg.eosq+146349.42*eoc
              g532 = -40023.88+170470.89*eq-242699.48*
                satellite.deep_arg.eosq+115605.82*eoc
            end # End if (eq <= 0.7)

            sini2 = satellite.deep_arg.sinio*satellite.deep_arg.sinio
            f220 = 0.75*(1+2*satellite.deep_arg.cosio+satellite.deep_arg.theta2)
            f221 = 1.5*sini2
            f321 = 1.875*satellite.deep_arg.sinio*(1-2 *
                        satellite.deep_arg.cosio-3*satellite.deep_arg.theta2)
            f322 = -1.875*satellite.deep_arg.sinio*(1+2 *
                         satellite.deep_arg.cosio-3*satellite.deep_arg.theta2)
            f441 = 35*sini2*f220
            f442 = 39.3750*sini2*sini2
            f522 = 9.84375*satellite.deep_arg.sinio*(sini2*(1-2*satellite.deep_arg.cosio-5*
                           satellite.deep_arg.theta2)+0.33333333*(-2+4*satellite.deep_arg.cosio+
                                 6*satellite.deep_arg.theta2))
            f523 = satellite.deep_arg.sinio*(4.92187512*sini2*(-2-4*
                        satellite.deep_arg.cosio+10*satellite.deep_arg.theta2)+6.56250012
                  *(1+2*satellite.deep_arg.cosio-3*satellite.deep_arg.theta2))
            f542 = 29.53125*satellite.deep_arg.sinio*(2-8*
                     satellite.deep_arg.cosio+satellite.deep_arg.theta2*
                     (-12+8*satellite.deep_arg.cosio+10*satellite.deep_arg.theta2))
            f543 = 29.53125*satellite.deep_arg.sinio*(-2-8*satellite.deep_arg.cosio+
                     satellite.deep_arg.theta2*(12+8*satellite.deep_arg.cosio-10*
                           satellite.deep_arg.theta2))
            xno2 = satellite.dps.xnq*satellite.dps.xnq
            ainv2 = aqnv*aqnv
            temp1 = 3*xno2*ainv2
            temp = temp1*RPredict::Norad.ROOT22
            satellite.dps.d2201 = temp*f220*g201
            satellite.dps.d2211 = temp*f221*g211
            temp1 = temp1*aqnv
            temp = temp1*RPredict::Norad.ROOT32
            satellite.dps.d3210 = temp*f321*g310
            satellite.dps.d3222 = temp*f322*g322
            temp1 = temp1*aqnv
            temp = 2*temp1*RPredict::Norad.ROOT44
            satellite.dps.d4410 = temp*f441*g410
            satellite.dps.d4422 = temp*f442*g422
            temp1 = temp1*aqnv
            temp = temp1*RPredict::Norad.ROOT52
            satellite.dps.d5220 = temp*f522*g520
            satellite.dps.d5232 = temp*f523*g532
            temp = 2*temp1*RPredict::Norad.ROOT54
            satellite.dps.d5421 = temp*f542*g521
            satellite.dps.d5433 = temp*f543*g533
            satellite.dps.xlamo = xmao+satellite.tle.xnodeo+satellite.tle.xnodeo-satellite.dps.thgr-satellite.dps.thgr
            bfact = satellite.deep_arg.xmdot+satellite.deep_arg.xnodot+
              satellite.deep_arg.xnodot-thdt-thdt
            bfact = bfact+satellite.dps.ssl+satellite.dps.ssh+satellite.dps.ssh
          # if( !(satellite.dps.xnq < 0.0052359877) && (satellite.dps.xnq > 0.0034906585) )
          else
            satellite.flags |= RESONANCE_FLAG
            satellite.flags |= SYNCHRONOUS_FLAG
            # Synchronous resonance terms initialization
            g200 = 1+satellite.deep_arg.eosq*(-2.5+0.8125*satellite.deep_arg.eosq)
            g310 = 1+2*satellite.deep_arg.eosq
            g300 = 1+satellite.deep_arg.eosq*(-6+6.60937*satellite.deep_arg.eosq)
            f220 = 0.75*(1+satellite.deep_arg.cosio)*(1+satellite.deep_arg.cosio)
            f311 = 0.9375*satellite.deep_arg.sinio*satellite.deep_arg.sinio*
              (1+3*satellite.deep_arg.cosio)-0.75*(1+satellite.deep_arg.cosio)
            f330 = 1+satellite.deep_arg.cosio
            f330 = 1.875*f330*f330*f330
            satellite.dps.del1 = 3*satellite.dps.xnq*satellite.dps.xnq*aqnv*aqnv
            satellite.dps.del2 = 2*satellite.dps.del1*f220*g200*q22
            satellite.dps.del3 = 3*satellite.dps.del1*f330*g300*q33*aqnv
            satellite.dps.del1 = satellite.dps.del1*f311*g310*q31*aqnv
            satellite.dps.fasx2 = 0.13130908
            satellite.dps.fasx4 = 2.8843198
            satellite.dps.fasx6 = 0.37448087
            satellite.dps.xlamo = xmao+satellite.tle.xnodeo+satellite.tle.omegao-satellite.dps.thgr
            bfact = satellite.deep_arg.xmdot+xpidot-thdt
            bfact = bfact+satellite.dps.ssl+satellite.dps.ssg+satellite.dps.ssh
          end # End if( !(xnq < 0.0052359877) && (xnq > 0.0034906585) )

          satellite.dps.xfact = bfact-satellite.dps.xnq

          # Initialize integrator
          satellite.dps.xli = satellite.dps.xlamo
          satellite.dps.xni = satellite.dps.xnq
          satellite.dps.atime = 0
          satellite.dps.stepp = 720
          satellite.dps.stepn = -720
          satellite.dps.step2 = 259200
          # End case dpinit:
          return satellite

        case RPredict::Norad.DPSEC: # Entrance for deep space secular effects

          satellite.deep_arg.xll = satellite.deep_arg.xll+satellite.dps.ssl*satellite.deep_arg.t
          satellite.deep_arg.omgadf = satellite.deep_arg.omgadf+satellite.dps.ssg*satellite.deep_arg.t
          satellite.deep_arg.xnode = satellite.deep_arg.xnode+satellite.dps.ssh*satellite.deep_arg.t
          satellite.deep_arg.em = satellite.tle.eo+satellite.dps.sse*satellite.deep_arg.t
          satellite.deep_arg.xinc = satellite.tle.xincl+satellite.dps.ssi*satellite.deep_arg.t
          if (satellite.deep_arg.xinc < 0)
            satellite.deep_arg.xinc = -satellite.deep_arg.xinc
            satellite.deep_arg.xnode = satellite.deep_arg.xnode + pi
            satellite.deep_arg.omgadf = satellite.deep_arg.omgadf-pi
          end

          if( ~satellite.flags & RESONANCE_FLAG )
            return satellite
          end

          begin
            if( (satellite.dps.atime == 0) ||
                ((satellite.deep_arg.t >= 0) && (satellite.dps.atime < 0)) ||
                ((satellite.deep_arg.t < 0) && (satellite.dps.atime >= 0)) )
              # Epoch restart
              if( satellite.deep_arg.t >= 0 )
                delt = satellite.dps.stepp
              else
                delt = satellite.dps.stepn
              end

              satellite.dps.atime = 0
              satellite.dps.xni = satellite.dps.xnq
              satellite.dps.xli = satellite.dps.xlamo
            else
              if( fabs(satellite.deep_arg.t) >= fabs(satellite.dps.atime) )
                if ( satellite.deep_arg.t > 0 )
                  delt = satellite.dps.stepp
                else
                  delt = satellite.dps.stepn
                end
              end
            end

            begin
              if ( fabs(satellite.deep_arg.t-satellite.dps.atime) >= satellite.dps.stepp )
                satellite.flags |= DO_LOOP_FLAG
                satellite.flags &= ~EPOCH_RESTART_FLAG
              else
                ft = satellite.deep_arg.t-satellite.dps.atime
                satellite.flags &= ~DO_LOOP_FLAG
              end

              if( fabs(satellite.deep_arg.t) < fabs(satellite.dps.atime) )
                if (satellite.deep_arg.t >= 0)
                  delt = satellite.dps.stepn
                else
                  delt = satellite.dps.stepp
                end
                satellite.flags |= (DO_LOOP_FLAG | EPOCH_RESTART_FLAG)
              end

              # Dot terms calculated
              if (satellite.flags & SYNCHRONOUS_FLAG)
                xndot = satellite.dps.del1*
                         Math::sin(satellite.dps.xli-satellite.dps.fasx2)+
                         satellite.dps.del2 *
                         Math::sin(2*(satellite.dps.xli-satellite.dps.fasx4))
                         +satellite.dps.del3*
                         Math::sin(3*(satellite.dps.xli-satellite.dps.fasx6))
                xnddt = satellite.dps.del1*Math::cos(satellite.dps.xli-satellite.dps.fasx2)+
                        2*satellite.dps.del2*
                        Math::cos(2*(satellite.dps.xli-satellite.dps.fasx4))+3 *
                        satellite.dps.del3*
                        Math::cos(3*(satellite.dps.xli-satellite.dps.fasx6))
              else
                xomi = satellite.dps.omegaq+satellite.deep_arg.omgdot*satellite.dps.atime
                x2omi = xomi+xomi
                x2li = satellite.dps.xli+satellite.dps.xli
                xndot = satellite.dps.d2201*Math::sin(x2omi+satellite.dps.xli-g22)
                  +satellite.dps.d2211*Math::sin(satellite.dps.xli-g22)
                  +satellite.dps.d3210*Math::sin(xomi+satellite.dps.xli-g32)
                  +satellite.dps.d3222*Math::sin(-xomi+satellite.dps.xli-g32)
                  +satellite.dps.d4410*Math::sin(x2omi+x2li-g44)
                  +satellite.dps.d4422*Math::sin(x2li-g44)
                  +satellite.dps.d5220*Math::sin(xomi+satellite.dps.xli-g52)
                  +satellite.dps.d5232*Math::sin(-xomi+satellite.dps.xli-g52)
                  +satellite.dps.d5421*Math::sin(xomi+x2li-g54)
                  +satellite.dps.d5433*Math::sin(-xomi+x2li-g54)
                xnddt = satellite.dps.d2201*Math::cos(x2omi+satellite.dps.xli-g22)
                  +satellite.dps.d2211*Math::cos(satellite.dps.xli-g22)
                  +satellite.dps.d3210*Math::cos(xomi+satellite.dps.xli-g32)
                  +satellite.dps.d3222*Math::cos(-xomi+satellite.dps.xli-g32)
                  +satellite.dps.d5220*Math::cos(xomi+satellite.dps.xli-g52)
                  +satellite.dps.d5232*Math::cos(-xomi+satellite.dps.xli-g52)
                  +2*(satellite.dps.d4410*Math::cos(x2omi+x2li-g44)
                      +satellite.dps.d4422*Math::cos(x2li-g44)
                      +satellite.dps.d5421*Math::cos(xomi+x2li-g54)
                      +satellite.dps.d5433*Math::cos(-xomi+x2li-g54))
              end # End of if (isFlagSet(SYNCHRONOUS_FLAG))

              xldot = satellite.dps.xni+satellite.dps.xfact
              xnddt = xnddt*xldot

              if(satellite.flags & DO_LOOP_FLAG)
                satellite.dps.xli = satellite.dps.xli+xldot*delt+xndot*satellite.dps.step2
                satellite.dps.xni = satellite.dps.xni+xndot*delt+xnddt*satellite.dps.step2
                satellite.dps.atime = satellite.dps.atime+delt
              end
            end while ( (satellite.flags & DO_LOOP_FLAG) &&
              (~satellite.flags & EPOCH_RESTART_FLAG))

          end  while ((satellite.flags & DO_LOOP_FLAG) && (satellite.flags & EPOCH_RESTART_FLAG))

          satellite.deep_arg.xn = satellite.dps.xni+xndot*ft+xnddt*ft*ft*0.5
          xl = satellite.dps.xli+xldot*ft+xndot*ft*ft*0.5
          temp = -satellite.deep_arg.xnode+satellite.dps.thgr+satellite.deep_arg.t*thdt

          if (~satellite.flags & SYNCHRONOUS_FLAG)
            satellite.deep_arg.xll = xl+temp+temp
          else
            satellite.deep_arg.xll = xl-satellite.deep_arg.omgadf+temp
          end
          return satellite
          #End case RPredict::Norad.DPSEC:

        case RPredict::Norad.DPPER: # Entrance for lunar-solar periodics
          sinis = Math::sin(satellite.deep_arg.xinc)
          cosis = Math::cos(satellite.deep_arg.xinc)
          if (fabs(satellite.dps.savtsn-satellite.deep_arg.t) >= 30)
            satellite.dps.savtsn = satellite.deep_arg.t
            zm = satellite.dps.zmos+RPredict::NOrad.ZNS*satellite.deep_arg.t
            zf = zm+2*RPredict::NOrad.ZES*Math::sin(zm)
            sinzf = Math::sin(zf)
            f2 = 0.5*sinzf*sinzf-0.25
            f3 = -0.5*sinzf*Math::cos(zf)
            ses = satellite.dps.se2*f2+satellite.dps.se3*f3
            sis = satellite.dps.si2*f2+satellite.dps.si3*f3
            sls = satellite.dps.sl2*f2+satellite.dps.sl3*f3+satellite.dps.sl4*sinzf
            satellite.dps.sghs = satellite.dps.sgh2*f2+satellite.dps.sgh3*f3+satellite.dps.sgh4*sinzf
            satellite.dps.shs = satellite.dps.sh2*f2+satellite.dps.sh3*f3
            zm = satellite.dps.zmol+znl*satellite.deep_arg.t
            zf = zm+2*zel*Math::sin(zm)
            sinzf = Math::sin(zf)
            f2 = 0.5*sinzf*sinzf-0.25
            f3 = -0.5*sinzf*Math::cos(zf)
            sel = satellite.dps.ee2*f2+satellite.dps.e3*f3
            sil = satellite.dps.xi2*f2+satellite.dps.xi3*f3
            sll = satellite.dps.xl2*f2+satellite.dps.xl3*f3+satellite.dps.xl4*sinzf
            satellite.dps.sghl = satellite.dps.xgh2*f2+satellite.dps.xgh3*f3+satellite.dps.xgh4*sinzf
            satellite.dps.sh1 = satellite.dps.xh2*f2+satellite.dps.xh3*f3
            satellite.dps.pe = ses+sel
            satellite.dps.pinc = sis+sil
            satellite.dps.pl = sls+sll
          end

          pgh = satellite.dps.sghs+satellite.dps.sghl
          ph = satellite.dps.shs+satellite.dps.sh1
          satellite.deep_arg.xinc = satellite.deep_arg.xinc+satellite.dps.pinc
          satellite.deep_arg.em = satellite.deep_arg.em+satellite.dps.pe

          if (satellite.dps.xqncl >= 0.2)
            # Apply periodics directly
            ph = ph/satellite.deep_arg.sinio
            pgh = pgh-satellite.deep_arg.cosio*ph
            satellite.deep_arg.omgadf = satellite.deep_arg.omgadf+pgh
            satellite.deep_arg.xnode = satellite.deep_arg.xnode+ph
            satellite.deep_arg.xll = satellite.deep_arg.xll+satellite.dps.pl
          else
            # Apply periodics with Lyddane modification
            sinok = Math::sin(satellite.deep_arg.xnode)
            cosok = Math::cos(satellite.deep_arg.xnode)
            alfdp = sinis*sinok
            betdp = sinis*cosok
            dalf = ph*cosok+satellite.dps.pinc*cosis*sinok
            dbet = -ph*sinok+satellite.dps.pinc*cosis*cosok
            alfdp = alfdp+dalf
            betdp = betdp+dbet
            satellite.deep_arg.xnode = RPredict.SGPMath.fMod2p(satellite.deep_arg.xnode)
            xls = satellite.deep_arg.xll+satellite.deep_arg.omgadf+cosis*satellite.deep_arg.xnode
            dls = satellite.dps.pl+pgh-satellite.dps.pinc*satellite.deep_arg.xnode*sinis
            xls = xls+dls
            xnoh = satellite.deep_arg.xnode
            satellite.deep_arg.xnode = Math::atan(alfdp,betdp)

            # This is a patch to Lyddane modification
            # suggested by Rob Matson.
            if(fabs(xnoh-satellite.deep_arg.xnode) > pi)
              if(satellite.deep_arg.xnode < xnoh)
                satellite.deep_arg.xnode +=Rpredic::Norad.TWOPI
              else
                satellite.deep_arg.xnode -=Rpredic::Norad.TWOPI
              end
            end


            satellite.deep_arg.xll = satellite.deep_arg.xll+satellite.dps.pl
            satellite.deep_arg.omgadf = xls-satellite.deep_arg.xll-cos(satellite.deep_arg.xinc)*
                                   satellite.deep_arg.xnode
          end # End case RPredict::Norad.DPPER:
          return satellite

        end # End switch(ientry)

      end # End of Deep()

  end
end