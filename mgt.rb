require 'rpredict'



name =  "TEME example"
line1 =  "1 88888U          80275.98708465  .00073094  13844-3  66816-4 0     9"
line2 =  "2 88888  72.8435 115.9689 0086731  52.6988 110.5714 16.05824518   103"
satellite =   RPredict::Satellite.new(name,line1,line2)

expected =[[0.0, 2328.97048951, -5995.22076416, 1719.97067261,2.91207230, -0.98341546, -7.09081703 ],
                   [ 360.0,2456.10705566, -6071.93853760, 1222.89727783,2.67938992, -0.44829041, -7.22879231 ],
                   [ 720.0,2567.56195068, -6112.50384522, 713.96397400,2.44024599, 0.09810869, -7.31995916 ],
                   [ 1080.0,2663.09078980, -6115.48229980, 196.39640427,2.19611958, 0.65241995, -7.36282432],
                   [1440.0, 2742.55133057, -6079.67144775, -326.38095856,1.94850229, 1.21106251, -7.35619372]]

satellite.select_ephemeris()

p "DEEP_SPACE_EPHEM: #{satellite.flags & RPredict::Norad::DEEP_SPACE_EPHEM_FLAG} (expected 0)"
i=0
p "                           RESULT                EXPECTED                DELTA"
p "--------------------------------------------------------------------------------------------"

expected.each do |t,x,y,z,vx,vy,vz|



  satellite = RPredict::SGPSDP.sgp4(satellite,t)
  satellite.position, satellite.velocity = RPredict::SGPMath.convert_Sat_State(satellite.position, satellite.velocity)
  p "STEP #{i+=1}  t: #{format("%6.1f",t)}  X: #{format("%14.8f",satellite.position.x)}
          #{format("%14.8f",x)}   #{format("%.8f",(satellite.position.x - x).abs)}
         (#{format("%.5f%%",100.0 * (satellite.position.x - x).abs/(x).abs)})"

  p "                   Y: #{format("%14.8f",satellite.position.y)}
          #{format("%14.8f",y)}   #{format("%.8f",(satellite.position.y - y).abs)}
         (#{format("%.5f%%",100.0 * (satellite.position.y - y).abs/(y).abs)})"

  p "                   Z: #{format("%14.8f",satellite.position.z)}
          #{format("%14.8f",z)}   #{format("%.8f",(satellite.position.z - z).abs)}
         (#{format("%.5f%%",100.0 * (satellite.position.z - z).abs/(z).abs)})"

  p "                   VX: #{format("%14.8f",satellite.velocity.x)}
          #{format("%14.8f",vx)}   #{format("%.8f",(satellite.velocity.x - vx).abs)}
         (#{format("%.5f%%",100.0 * (satellite.velocity.x - vx).abs/(vx).abs)})"

  p "                   VY: #{format("%14.8f",satellite.velocity.y)}
          #{format("%14.8f",vy)}   #{format("%.8f",(satellite.velocity.y - vy).abs)}
         (#{format("%.5f%%",100.0 * (satellite.velocity.y - vy).abs/(vy).abs)})"


  p "                   VZ: #{format("%14.8f",satellite.velocity.z)}
          #{format("%14.8f",vz)}   #{format("%.8f",(satellite.velocity.z - vz).abs)}
         (#{format("%.5f%%",100.0 * (satellite.velocity.z - vz).abs/(vz).abs)})"


end



