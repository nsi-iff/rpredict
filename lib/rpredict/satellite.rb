module RPredict
  module Satellite
    autoload :Satellite, 'rpredict/satellite/satellite'
    autoload :TLE, 'rpredict/satellite/tle'
    autoload :TLEImport, 'rpredict/satellite/tleimport'
    autoload :TLEImportFromFile, 'rpredict/satellite/tleimportfromfile'

    def self.new(*params)
      Satellite.new(*params)
    end
  end
end