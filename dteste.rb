require 'time'
require 'date'
require 'rpredict'

year = 2015
days = 300

p RPredict::DateUtil.julian_Date_of_Year(year) + days

mon,day,hr,minute,sec = RPredict::DateUtil.days2mdhms(year,days)
p RPredict::DateUtil.julianday(year,mon,day,hr,minute,sec)

daynum = RPredict::DateUtil.day("2015-04-07 17:32:29")
daynum2 = RPredict::DateUtil.day("2015-05-07 17:32:29")
daynum10 = daynum + 30.0

p "Diferença     #{daynum2 - daynum}"
p "Diferença 10  #{daynum10 - daynum}"

p "inv #{RPredict::DateUtil.invjulianday_DateTime(daynum2)}"
p "inv #{RPredict::DateUtil.invjulianday_DateTime(daynum10)}"
#t = Time.new(2015,5,5,10,10,10).utc
t = Time.now.utc
d = DateTime.new(2015,5,5,10,10,10)

p t.utc?
p "t         = #{t}"
p "Datetime  = #{DateTime.parse(t.to_s)}"
p "d         = #{d}"
p "Time      = #{Time.parse(d.to_s)}"


