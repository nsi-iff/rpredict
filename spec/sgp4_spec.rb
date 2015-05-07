require 'spec_helper'

describe RPredict::SGPSDP  do

  let(:name) {"TEME example"}
  let(:line1) {"1 88888U          80275.98708465  .00073094  13844-3  66816-4 0     9"}
  let(:line2) {"2 88888  72.8435 115.9689 0086731  52.6988 110.5714 16.05824518   103"}
  let(:satellite) { RPredict::Satellite.new(name,line1,line2)}

  let(:expected) {[[0.0, 2328.970704139636, -5995.22076416, 1719.97067261,2.91207230, -0.98341546, -7.09081703 ],
                   [ 360.0,2456.1078417981685, -6071.93853760, 1222.89727783,2.67938992, -0.44829041, -7.22879231 ],
                   [ 720.0,2567.5628397137652, -6112.50384522, 713.96397400,2.44024599, 0.09810869, -7.31995916 ]]}

  it 'Test Deep Space' do
    expect(satellite.flags & RPredict::Norad::DEEP_SPACE_EPHEM_FLAG ).to eq 0
  end

  it 'Test SGP4' do
    satellite.select_ephemeris()
    expected.each do |t,x,y,z,vx,vy,vz|


      satellite.localization(t)
      satellite.position, satellite.velocity = RPredict::SGPMath.convert_Sat_State(satellite.position, satellite.velocity)
      expect(satellite.position.x).to eq x
    end
  end



end