require "rpredict/version"

module RPredict
  autoload :SGPMath, 'rpredict/sgpmath'
  autoload :DateUtil, 'rpredict/date'
  autoload :Satellite, 'rpredict/satellite'
  autoload :Norad, 'rpredict/norad'
  autoload :Geodetic , 'rpredict/geodetic'
  autoload :SGPSDP  , 'rpredict/sgp4sdp4'
  autoload :OrbitTools  , 'rpredict/orbit_tools'
  autoload :Observer, 'rpredict/observer'
  autoload :Ephemeris, 'rpredict/ephemeris'
  autoload :SatellitePass, 'rpredict/satellite_pass'
  autoload :Exceptions, 'rpredict/exceptions'

end
