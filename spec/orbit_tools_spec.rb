require 'spec_helper'

describe RPredict::OrbitTools  do

  let(:name) {"TEME example"}
  let(:line1) {"1 00005U 58002B   00179.78495062  .00000023  00000-0  28098-4 0  4753"}
  let(:line2) {"2 00005  34.2682 348.7242 1859667 331.7664  19.3264 10.82419157413667"}
  let(:satellite) { RPredict::Norad.select_ephemeris(RPredict::Satellite.new(name,line1,line2))}
  let(:latitude) {21.40}
  let(:longitude) {-41.50}
  let(:altitude) {100.0}
  let(:observer) { RPredict::Observer.new(latitude,longitude,altitude)}

  it 'Test geostationary' do
    expect(RPredict::OrbitTools.geostationary?(satellite)).to eq false
  end

  it 'Test decayed?' do
    expect(RPredict::OrbitTools.decayed?(satellite)).to eq false
  end

  it 'Test has_AOS?' do
    expect(RPredict::OrbitTools.has_AOS?(satellite,observer)).to eq true
  end

end