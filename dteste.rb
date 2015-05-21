require 'time'
require 'date'
require 'rpredict'

year = 2015
days = 300

daynum = RPredict::DateUtil.day("2015-04-07 17:32:29")
daynum2 = RPredict::DateUtil.day("2015-04-07 17:32:30")
daynum10 = daynum + 0.000001

p "Diferença     #{daynum2 - daynum}"
p "Diferença 10  #{daynum10 - daynum}"

p "inv    #{RPredict::DateUtil.invjulianday_DateTime(daynum)}"
p "inv 02 #{RPredict::DateUtil.invjulianday_DateTime(daynum2)}"
p "inv 10 #{RPredict::DateUtil.invjulianday_DateTime(daynum10)}"
