module RPredict
  module Satellite
    class Satellite

      attr_accessor :tle, :ephemeris, :geodetic

      def initialize(name,line1,line2)
        @tle = RPredict::Satellite::TLE.new(name,line1,line2)
        #@ephemeris = RPredict::Ephemeris.new
        #@geodetic  = RPredict::Geodetic.new
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