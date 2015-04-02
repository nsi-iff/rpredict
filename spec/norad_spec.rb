require 'spec_helper'

describe RPredict::Norad  do
  let(:name) {"TEME example"}
  let(:line1) {"1 00005U 58002B   00179.78495062  .00000023  00000-0  28098-4 0  4753"}
  let(:line2) {"2 00005  34.2682 348.7242 1859667 331.7664  19.3264 10.82419157413667"}
  let(:nameGS) {"Campos"}
  let(:latitude) {-21.7500}
  let(:longitude) {-41.3000}
  let(:altitude) {15.0}

  #let (:predict) {RPredict::Predict.new(name,line1,line2,nameGS,latitude,longitude,altitude)}

  it 'get TwoPI' do
    expect(RPredict::Norad::TWOPI).to eq 6.283185307179586
  end

  it 'get Two PI' do
    expect(RPredict::Norad::PI2).to eq 1.5707963267948966
  end


end

