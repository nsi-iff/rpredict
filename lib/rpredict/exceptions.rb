module RPredict
  module Exceptions
    autoload :SatelliteException, 'rpredict/exceptions/exceptionClass'
    autoload :TleException, 'rpredict/exceptions/exceptionClass'
    autoload :URLException, 'rpredict/exceptions/exceptionClass'
    autoload :GeneralException, 'rpredict/exceptions/exceptionClass'
    autoload :ObserverException, 'rpredict/exceptions/exceptionClass'
    autoload :UnknownSatellite, 'rpredict/exceptions/exceptionClass'

    def self.new(*params)
      Exception.new(*params)
    end
  end
end
