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
daynum = RPredict::DateUtil.day("2015-05-07 17:32:29")
daynum2 = RPredict::DateUtil.day("2015-05-07 17:52:29")

#daynum =  RPredict::DateUtil.currentDay
#daynum = RPredict::DateUtil.day("2015-04-28 14:03:20")
#daynum = RPredict::DateUtil.julianday(2015,04,28,14,03,20)

=begin
ephemeris = observer.calculate(satellite, daynum)


idt = RPredict::DateUtil.invjulianday_DateTime(daynum)


p "Daynum #{daynum} date ==>#{RPredict::DateUtil.daynum2Date(RPredict::DateUtil.currentDaynum())} #{RPredict::DateUtil.currentDaynum()}"
p "Invjulianday_dateTime #{idt}"
p "satellite.position.x #{RPredict::SGPMath.deg2rad(satellite.position.x)} satellite.position.y #{RPredict::SGPMath.rad2deg(satellite.position.y)}"
p "Azimuth = > #{ephemeris.azimuth} Elevation => #{ephemeris.elevation}"
p "Velo #{satellite.veloc}"
p "+++++++++++++++++++++++++++++++++++++++++++++++++++++++"
p "======================================================="
=end
daynow = RPredict::DateUtil.day("2015-05-14 0:0:0")# RPredict::DateUtil.currentDayTime()
satellite.select_ephemeris()
satellite = observer.calculate(satellite, daynow)
p "Proxima passada aos #{RPredict::DateUtil.invjulianday_DateTime(observer.find_AOS(satellite,daynow))}"
p "Proxima passada los #{RPredict::DateUtil.invjulianday_DateTime(observer.find_LOS(satellite,daynow))}"

