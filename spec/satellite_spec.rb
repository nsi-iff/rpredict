require 'spec_helper'

describe RPredict::Satellite  do
  let(:name) {"TEME example"}
  let(:line1) {"1 00005U 58002B   00179.78495062  .00000023  00000-0  28098-4 0  4753"}
  let(:line2) {"2 00005  34.2682 348.7242 1859667 331.7664  19.3264 10.82419157413667"}
  let(:satellite) { RPredict::Satellite.new(name,line1,line2)}
  let(:elevation) {10.0}
  let(:azimuth) {10.0}
  let(:sgps) { RPredict::Norad.sgpsdp_static_t()}
  let(:dps) {RPredict::Norad.deep_static_t()}
  let(:deep_arg) {RPredict::Norad.deep_arg_t()}
=begin
  let(:ephemeris) {RPredict::Ephemeris.new(elevation,azimuth)}

  it 'get ephemeris' do
     satellite.ephemeris = ephemeris
     expect(satellite.ephemeris.elevation).to eq elevation
     expect(satellite.ephemeris.azimuth).to eq azimuth
  end
=end

  it 'get Satellite name from TLE' do
    expect(satellite.tle.name).to eq name
  end

  it 'get Satellite Line1 from TLE' do
    expect(satellite.tle.line1).to eq line1
  end

  it 'get Satellite Line2 from TLE' do
    expect(satellite.tle.line2).to eq line2
  end

  it 'get catnum' do
    expect(satellite.catnum).to eq 5
  end

  it 'get setnum' do
    expect(satellite.setnum).to eq " 475".to_i
  end

  it 'get designator' do
    expect(satellite.designator).to eq "58002B  "
  end

  it 'get year' do
    expect(satellite.year).to eq 2000
  end

  it 'get refepoch' do
    expect(satellite.refepoch).to eq "179.78495062".to_f
  end

  it 'get incl' do
    expect(satellite.incl).to eq " 34.2682".to_f
  end

  it 'get raan' do
    expect(satellite.raan).to eq "348.7242".to_f
  end

  it 'get eccn' do
     expect(satellite.eccn).to eq 0.1859667
  end

  it 'get argper' do
    expect(satellite.argper).to eq "331.7664".to_f
  end

  it 'get meanan' do
    expect(satellite.meanan).to eq "19.3264".to_f
  end

  it 'get meanmo' do
    expect(satellite.meanmo).to eq "10.82419157".to_f
  end

  it 'get drag' do
    expect(satellite.drag).to eq " .00000023".to_f
  end



  it 'get orbitnum' do
    expect(satellite.orbitnum).to eq "41366".to_i
  end

  it 'get flags' do
    expect(satellite.flags).to eq 0
  end

end
