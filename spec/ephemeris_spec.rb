require 'spec_helper'

describe RPredict::Ephemeris  do
  let(:elevation) {0.0}
  let(:azimuth) {21.7500}
  let(:range) {41.3000}
  let(:range_rate) {15.0}
  let(:ephemeris) {RPredict::Ephemeris.new(azimuth,elevation,range,range_rate)}

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

