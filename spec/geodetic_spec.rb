require 'spec_helper'

describe RPredict::Geodetic  do
  let(:theta) {0.0}
  let(:latitude) {-21.7500}
  let(:longitude) {-41.3000}
  let(:altitude) {15.0}
  let(:geodetic) { RPredict::Geodetic.new(latitude,longitude,altitude,theta)}

  it 'get Geodetic theta ' do
    expect(geodetic.theta).to eq theta
  end

  it 'get Geodetic latitude ' do
    expect(geodetic.latitude).to eq latitude
  end

  it 'get Geodetic longitude ' do
    expect(geodetic.longitude).to eq longitude
  end

  it 'get Geodetic Altitude' do
    expect(geodetic.altitude).to eq altitude
  end


end

