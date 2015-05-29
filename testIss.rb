require 'rpredict'


name =  "ISS (ZARYA) "
line1 =  "1 25544U 98067A   15119.57674883  .00015278  00000-0  21995-3 0  9997"
line2 =  "2 25544  51.6470 326.8384 0005314 280.3312 119.8189 15.56237854940478"

satellite =   RPredict::Satellite.new(name,line1,line2)

latitude  = -21.7545
longitude = -41.3244
altitude  = 15.0
observer  =  RPredict::Observer.new(latitude,longitude,altitude)
#daynum = RPredict::DateUtil.julianday(2015,05,07,16,48,10)
daynum = RPredict::DateUtil.day("2015-05-18 12:00:00")
satellite.select_ephemeris()

outFile = File.new("../ephem18.txt","w")
outFile.puts(" Data       Hora     Azimuth  Elevation \n")
outFile.puts(" \n")

  satellitePass = observer.getPass(satellite,daynum)
  daynum = satellitePass.ephemerisAOS.dateTime
  while daynum <= satellitePass.ephemerisLOS.dateTime
    satellite, ephemeris = observer.calculate(satellite,daynum)
    dia = RPredict::DateUtil.invjulianday_DateTime(ephemeris.dateTime).strftime("%Y-%m-%d %H:%M:%S")
    outFile.puts("#{dia}  #{format("%4.1f",ephemeris.azimuth)}  #{format("%5.1f",ephemeris.elevation)}")
    daynum +=  RPredict::Norad::SECOND
  end
  outFile.puts(" \n")
outFile.close()