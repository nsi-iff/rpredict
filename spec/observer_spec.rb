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
  let(:satelliteEphem) {observer.calculate(satellite, daynum)}

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

    expect(satelliteEphem.ephemeris.azimuth).to eq azim
    expect(satelliteEphem.ephemeris.elevation).to eq elev
  end

  it 'get calculate aos' do
     expect(observer.find_AOS(satellite,daynum)).to eq aos
  end

  it 'get calculate los' do
     expect(observer.find_LOS(satellite,daynum)).to eq los
  end

end
