require 'spec_helper'

describe RPredict::GroundStation  do
  let(:latitude) {21.40}
  let(:longitude) {-41.50}
  let(:altitude) {100.0}
  let(:groundStation) { RPredict::GroundStation.new(latitude,longitude,altitude)}


  it 'get GroundStation latitude' do
    expect(groundStation.geodetic.latitude).to eq latitude
  end

  it 'get GroundStation longitude' do
    expect(groundStation.geodetic.longitude).to eq longitude
  end

  it 'get GroundStation altitude' do
    expect(groundStation.geodetic.altitude).to eq altitude
  end

end
