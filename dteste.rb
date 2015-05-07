require 'time'
require 'date'
require 'rpredict'

year = 2015
days = 300

p RPredict::DateUtil.julian_Date_of_Year(year) + days

mon,day,hr,minute,sec = RPredict::DateUtil.days2mdhms(year,days)
p RPredict::DateUtil.julianday(year,mon,day,hr,minute,sec)


#t = Time.new(2015,5,5,10,10,10).utc
t = Time.now.utc
d = DateTime.new(2015,5,5,10,10,10)

p t.utc?
p "t         = #{t}"
p "Datetime  = #{DateTime.parse(t.to_s)}"
p "d         = #{d}"
p "Time      = #{Time.parse(d.to_s)}"
