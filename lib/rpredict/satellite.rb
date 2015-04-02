module RPredict
  module Satellite
    autoload :Satellite, 'rpredict/satellite/satellite'
    autoload :TLE, 'rpredict/satellite/tle'

    def self.new(*params)
      Satellite.new(*params)
    end
  end
end