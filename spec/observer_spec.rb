require 'spec_helper'

describe RPredict::Observer  do
  let(:latitude) {21.40}
  let(:longitude) {-41.50}
  let(:altitude) {100.0}
  let(:observer) { RPredict::Observer.new(latitude,longitude,altitude)}


  it 'get Observer latitude' do
    expect(observer.geodetic.latitude).to eq latitude
  end

  it 'get Observer longitude' do
    expect(observer.geodetic.longitude).to eq longitude
  end

  it 'get Observer altitude' do
    expect(observer.geodetic.altitude).to eq altitude
  end

end
