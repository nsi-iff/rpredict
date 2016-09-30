module RPredict
  module Exceptions
    class SatelliteException < Exception
    end

    class TleException < Exception
    end

    class URLException < Exception
    end

    class GeneralException < Exception
    end

    class ObserverException < Exception
    end

    class UnknownSatellite < Exception
    end
  end
end
