
require 'rpredict'


daynum = RPredict::DateUtil.day("2015-04-07 17:32:29")
daynum2 = RPredict::DateUtil.day("2015-04-07 17:32:30")
#daynum10 = (daynum + (2*0.000011574))

p "inv    29 daynum   #{daynum}  #{RPredict::DateUtil.invjulianday_DateTime(daynum)}"
p "inv 02 30 daynum2  #{daynum2}  #{RPredict::DateUtil.invjulianday_DateTime(daynum2)}"
for i in 1..10
daynum10 = (daynum + (i*RPredict::Norad::SECOND))

p "inv 10 #{i} daynum10 #{daynum10} #{RPredict::DateUtil.invjulianday_DateTime(daynum10)}"
end
