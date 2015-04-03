require 'spec_helper'

describe RPredict::SGPMath  do

  let(:value) { 10 }
  let(:magv) {RPredict::Norad.vector_t(1,2,3)}
  let(:vsca) {RPredict::Norad.vector_t(3,6,9)}

  it 'vector_t test' do
    expect(magv.x).to eq 1
    expect(magv.y).to eq 2
    expect(magv.z).to eq 3
    expect(magv.w).to eq 0

  end
  it 'magnitude test' do
     expect(RPredict::SGPMath.magnitude(magv)).to eq 3.7416573867739413
  end
  it 'pow test' do
    expect(RPredict::SGPMath.pow(2,3)).to eq 8
  end

  it 'sqr test' do
    expect(RPredict::SGPMath.sqr(5)).to eq 25
  end

  it 'cube test' do
    expect(RPredict::SGPMath.cube(5)).to eq 125
  end

  it 'signal test' do
    expect(RPredict::SGPMath.signal(value)).to eq 1.0
  end

  it 'Convert degrees to Rad ' do
    expect(RPredict::SGPMath.deg2rad(1.0)).to eq (Math::PI/180)
  end

  it 'scalar Vector test' do
    expect(RPredict::SGPMath.scale_Vector(3,magv)) == vsca
  end

  it 'scalar_Multiply test' do
    expect(RPredict::SGPMath.scalar_Multiply(3,magv)) == vsca
  end

end