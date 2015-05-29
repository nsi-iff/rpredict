require 'rpredict'



name =  "ISS (ZARYA) "
line1 =  "1 25544U 98067A   15119.57674883  .00015278  00000-0  21995-3 0  9997"
line2 =  "2 25544  51.6470 326.8384 0005314 280.3312 119.8189 15.56237854940478"

satellite =   RPredict::Satellite.new(name,line1,line2)

latitude  = -21.7545
longitude = -41.3244
altitude  = 15.0
observer  =  RPredict::Observer.new(latitude,longitude,altitude)



daypass = RPredict::DateUtil.day("2015-05-14 0:20:0")
daynow = RPredict::DateUtil.day("2015-05-18 15:0:0")

daynow = RPredict::DateUtil.day("2015-05-18 12:00:00")

satellite.select_ephemeris()
#satellite = observer.calculate(satellite, daynow)
p "daynow #{daynow}"


p "Proxima passada aos #{RPredict::DateUtil.invjulianday((observer.findAOS(satellite,daynow)).dateTime)}"
p "Proxima passada los #{RPredict::DateUtil.invjulianday((observer.findLOS(satellite,daynow)).dateTime)}"
p "Proxima passada Pre #{RPredict::DateUtil.invjulianday((observer.findPrevAOS(satellite,daynow)).dateTime)}"



p '====================================================================================='
satellitePass = observer.getPass(satellite, daynow)

p "Proxima passada aos #{RPredict::DateUtil.invjulianday(satellitePass.ephemerisAOS.dateTime)}"
p "Proxima passada tca #{RPredict::DateUtil.invjulianday(satellitePass.ephemerisTCA.dateTime)}"
p "Proxima passada los #{RPredict::DateUtil.invjulianday(satellitePass.ephemerisLOS.dateTime)}"


p '====================================================================================='

daynum = RPredict::DateUtil.day("2015-05-18 13:07:55")
satellite, ephemeris = observer.calculate(satellite,daynum)
dia = RPredict::DateUtil.invjulianday(ephemeris.dateTime).strftime("%Y-%m-%d %H:%M:%S")
p "#{dia}  #{format("%4.1f",ephemeris.azimuth)}  #{format("%5.1f",ephemeris.elevation)}"
