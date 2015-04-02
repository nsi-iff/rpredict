module RPredict
  module Satellite
    class TLE

      attr_accessor :name, :line1, :line2,:epoch, :xndt2o, :xndd6o, :xbstar,
                    :xincl, :xnodeo, :eo, :omegao, :xmo, :xno, :catnr, :elset,
                    :revnum


      def initialize(name,line1,line2)
        @name = name   #sat_name
        @line1 = line1
        @line2 = line2
        @xepoch = (1000.0 * epochyear) + epochday * 1 ##epoch
        @eo = 1.0e-07 * eccentricity
        @xndt2o = firstderivativmeanmotion * RPredict::Norad::TXX
        @xndd6o = nddot6 * RPredict::Norad::TXX/RPredict::Norad::XMNPDA
        @xbstar = bstar/RPredict::Norad::AE                    ##bstart
        @xincl = RPredict::SGPMath.deg2rad(incliniation) #
        @xnodeo = RPredict::SGPMath.deg2rad(rightascensionascendingnode)
        @omegao = RPredict::SGPMath.deg2rad(argumentperigge) #
        @xmo = RPredict::SGPMath.deg2rad(meananomaly) #
        @xno = meanmotion*(RPredict::Norad::TXX)*RPredict::Norad::XMNPDA #
        #@elset = 0

      end

      def bstar
        #bstardrag
        (1.0e-5*line1[53...59].to_f)/(10.0**line1[59...61].to_f)
      end

      def nddot6
        #tle.secondderivativemeanmotion
        (1.0e-5*line1[44...50].to_f)/(10.0**line1[50...52].to_f)
      end

      #----   Line 1  --------------
      # satnum Satellite - d --- catnr
      def satellitenumber
          @line1[02...07].to_i
      end

      # Classification Satellite - c - n
      def classification
          @line1[07]
      end

      # intldesg Satellite - s - n  -- idesg
      def internationaldesignator
          launchyear+launchnumber+launchpiece
      end

      def launchyear
          @line1[9...11]
      end

      def launchnumber
          @line1[11...14]
      end

      def launchpiece
          @line1[14...17]
      end

      def epoch
          @line1[18...32]
      end

      # epochyr Satellite - d - s
      def epochyear
          @line1[18...20].to_i
      end

      # epochdays Satellite - f -s
      def epochday
          @line1[20...32].to_f
      end

      # ndot Satellite - f - s
      def firstderivativmeanmotion
          @line1[33...43].to_f
      end

      # nddot Satellite - f -s
      def secondderivativemeanmotion
          ((@line1[44...50]).to_f/100000.0) * (10.0**(@line1[50...52]).to_i)
      end

      # bstar Satellite - f -s
      def bstardrag
          ((@line1[53...59]).to_f/100000.0) * (10.0**(@line1[59...61]).to_i)
      end

      # ibexep Satellite - d - n
      def ephemeristype
          (@line1[62]).to_i
      end

      #elnum Satellite - d - n
      def elementnumber
          @line1[64...68].to_i
      end


      # ------ Line 2 --------------

      #inclo Satellite f -s
      def incliniation
          (@line2[8...16]).to_f
      end

      # nodeo Satellite f - s raan - xnodeo
      def rightascensionascendingnode
          (@line2[17...25]).to_f
      end

      # ecco Satellite - f- s --eo--
      def eccentricity
          ("0."+@line2[26...33]).to_f
      end

      # argpo Satellite - f - s
      def argumentperigge
          (@line2[34...42]).to_f
      end

      # mo Satellite - f - s
      def meananomaly
          (@line2[43...51]).to_f
      end

      # no Satellite - f - s
      def meanmotion
          (@line2[52...63]).to_f
      end

      # revnum Satellite d - n
      def revolutionnumberepoch
          (@line2[63...68]).to_i
      end

    end
  end
end
