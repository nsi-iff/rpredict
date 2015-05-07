require 'spec_helper'

describe RPredict::Ephemeris  do
  let(:name) {"TEME example"}
  let(:line1) {"1 00005U 58002B   00179.78495062  .00000023  00000-0  28098-4 0  4753"}
  let(:line2) {"2 00005  34.2682 348.7242 1859667 331.7664  19.3264 10.82419157413667"}
  let(:satellite) { (RPredict::Satellite.new(name,line1,line2))}

  let(:latitude) {21.40}
  let(:longitude) {-41.50}
  let(:altitude) {100.0}
  let(:observer) { RPredict::Observer.new(latitude,longitude,altitude)}

  let(:elevation) {0.0}
  let(:azimuth) {21.7500}
  let(:range) {41.3000}
  let(:range_rate) {15.0}
  let(:ephemeris) {RPredict::Ephemeris.new(observer,satellite, azimuth,elevation,
                                           range,range_rate)}

   before(:each) do
    satellite.select_ephemeris()
   end

  it 'get Ephemeris Satellite name ' do
    expect(ephemeris.satellite.tle.name).to eq name
  end

  it 'get Ephemeris Observer latitude ' do
    expect(ephemeris.observer.geodetic.latitude).to eq latitude
  end

  it 'get Ephemeris elevation ' do
    expect(ephemeris.elevation).to eq elevation
  end

  it 'get Ephemeris azimuth ' do
    expect(ephemeris.azimuth).to eq azimuth
  end

  it 'get Ephemeris range ' do
    expect(ephemeris.range).to eq range
  end

  it 'get Ephemeris Altitude' do
    expect(ephemeris.range_rate).to eq range_rate
  end
end

