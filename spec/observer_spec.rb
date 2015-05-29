require 'spec_helper'

describe RPredict::Observer  do
  let(:latitude) {-21.7545}
  let(:longitude) {-41.3244}
  let(:altitude) {15.0}
  let(:observer) { RPredict::Observer.new(latitude,longitude,altitude)}
  let(:name) {"ISS (ZARYA)"}
  let(:line1) {"1 25544U 98067A   15119.57674883  .00015278  00000-0  21995-3 0  9997"}
  let(:line2) {"2 25544  51.6470 326.8384 0005314 280.3312 119.8189 15.56237854940478"}
  let(:satellite) { RPredict::Satellite.new(name,line1,line2)}
  let(:daynum) {RPredict::DateUtil.day("2015-05-14 0:0:0")}
  let(:azim) {221.95430471050685}
  let(:elev) {-37.45844443113333}
  let(:aos) {2457156.6360872667}
  let(:los) {2457156.643304261}
  let(:tca) {2457156.639721526}


  let(:satellitePass) { observer.getPass(satellite, daynum)}


   before(:each) do
    satellite.select_ephemeris()
   end

  it 'get Observer latitude' do
    expect(observer.geodetic.latitude).to eq latitude
  end

  it 'get Observer longitude' do
    expect(observer.geodetic.longitude).to eq longitude
  end

  it 'get Observer altitude' do
    expect(observer.geodetic.altitude).to eq altitude
  end

  it 'get calculate Ephemeris' do
    sat, ephem = observer.calculate(satellite, daynum)
    expect(ephem.azimuth).to eq azim
    expect(ephem.elevation).to eq elev
  end

  it 'get calculate aos' do
     expect((observer.findAOS(satellite,daynum)).dateTime).to eq aos
  end

  it 'get calculate los' do
     expect((observer.findLOS(satellite,daynum)).dateTime).to eq los
  end

  it 'get calculate findPrevAOS' do
     daypass = RPredict::DateUtil.day("2015-05-14 0:20:0")
     ephemAOS = observer.findPrevAOS(satellite,daypass)
     expect(ephemAOS.dateTime.round(2)).to eq aos.round(2)
  end

  it 'get getPass' do
     expect(satellitePass.ephemerisAOS.dateTime).to eq aos
     expect(satellitePass.ephemerisLOS.dateTime).to eq los
     expect(satellitePass.ephemerisTCA.dateTime).to eq tca
  end
  it 'get next pass' do
     expect((observer.nextPass(satellite,daynum)).dateTime).to eq aos

  end

end
