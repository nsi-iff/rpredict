require 'rpredict'



name =  "ISS (ZARYA) "
line1 =  "1 25544U 98067A   15107.19000354  .00020238  00000-0  29383-3 0  9999"
line2 =  "2 25544  51.6475  28.7577 0005784 225.9745 219.7227 15.55776911938540"



satellite =   RPredict::Satellite.new(name,line1,line2)


satellite = RPredict::Norad.select_ephemeris(satellite)

daynum = (DateTime.new(2015,04,18,0,0,0).strftime('%Q').to_f-315446400000)/86400000
jul_utc = daynum.to_f + 2444238.5
jul_epoch = RPredict::DateUtil.julian_Date_of_Epoch(satellite.tle.epoch);

t = (jul_utc - jul_epoch) * RPredict::Norad::XMNPDA

p "DEEP_SPACE_EPHEM: #{satellite.flags & RPredict::Norad::DEEP_SPACE_EPHEM_FLAG} (expected 0)"
i=0
p "                           RESULT                EXPECTED                DELTA"
p "--------------------------------------------------------------------------------------------"
satellite = RPredict::SGPSDP.sgp4(satellite,t)
satellite.position, satellite.velocity = RPredict::SGPMath.convert_Sat_State(satellite.position, satellite.velocity)

p "STEP #{i+=1}  t: #{format("%6.1f",t)}  X: #{format("%14.8f",RPredict::SGPMath.rad2deg(satellite.position.x))}"

p "                   Y: #{format("%14.8f",satellite.position.y)}"

p "                   Z: #{format("%14.8f",satellite.position.z)}"

p "                   VX: #{format("%14.8f",satellite.velocity.x)}"

p "                   VY: #{format("%14.8f",satellite.velocity.y)}"

p "                   VZ: #{format("%14.8f",satellite.velocity.z)}"



