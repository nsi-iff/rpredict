module RPredict
  module Satellite
    class TLE

      attr_accessor :name, :line1, :line2,:epoch, :xndt2o, :xndd6o, :xbstar,
                    :xincl, :xnodeo, :eo, :omegao, :xmo, :xno, :catnr, :elset,
                    :revnum, :bstar, :omegao1, :xincl1, :xnodeo1


      def initialize(name,line1,line2)
        @name = name   #sat_name
        @line1 = line1
        @line2 = line2
        @xnodeo = rightascensionascendingnode # f
        @omegao = argumentperigge #
        @xmo    = meananomaly #
        @xincl  = incliniation # f

        @xno    = meanmotion

        @xepoch = (1000.0 * epochyear) + epochday * 1 ##epoch
        @xndt2o = firstderivativmeanmotion
        @xndd6o = nddot6
        @xbstar = bstar
        @eo     =  eccentricity # * 1.0e-07
        @revnum = revolutionnumberepoch

      end

      def bstar
        #bstardrag
        (line1[53...59].to_f/100000)*(10.0**line1[59...61].to_f)
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
          2000 + @line1[18...20].to_i
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
          (@line1[44...50].to_f/100000.0) * (10.0**@line1[50...52].to_i)
      end

      def nddot6
        secondderivativemeanmotion

      end

      # bstar Satellite - f -s
      def bstardrag
          bstar
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
