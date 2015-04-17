require 'spec_helper'

describe RPredict::Satellite::TLE  do


  let(:name) {"TEME example"}
  let(:line1) {"1 00005U 58002B   00179.78495062  .00000023  00000-0  28098-4 0  4753"}
  let(:line2) {"2 00005  34.2682 348.7242 1859667 331.7664  19.3264 10.82419157413667"}
  let(:tle) { RPredict::Satellite::TLE.new(name,line1,line2)}

  it 'get TLE name ' do
    expect(tle.name).to eq name
  end

  it 'get TLE Line1 ' do
    expect(tle.line1).to eq line1
  end

  it 'get TLE Line2 ' do
    expect(tle.line2).to eq line2
  end


  it 'create_TwoLineElementSgpy4' do

      expect(tle.name).to eq name
      expect(tle.line1).to eq line1
      expect(tle.line2).to eq line2
  end

  it 'Satellite_Number' do
      expect(tle.satellitenumber).to eq  5
  end

  it 'classification' do
      expect(tle.classification).to eq "U"
  end

  it 'international_designator' do
      expect(tle.internationaldesignator).to eq "58002B  "
  end

  it 'epoch' do
      expect(tle.epoch).to eq "00179.78495062"
  end

  it 'epoch_year' do
      expect(tle.epochyear).to eq 2000
  end

  it 'epoch_days' do
      expect(tle.epochday).to eq "179.78495062".to_f
  end

  it 'first_derivativ_mean_motion' do
      expect(tle.firstderivativmeanmotion).to eq " .00000023".to_f
  end

  it 'second_derivative_mean_motion' do
      expect(tle.secondderivativemeanmotion).to eq ((" 00000").to_f/100000.0) * (10.0**("-0").to_i)
  end

  it 'bstardrag' do
      expect(tle.bstardrag).to eq ((" 28098").to_f/100000.0) * (10.0**("-4").to_i)
  end

  it 'ephemeris_type' do
      expect(tle.ephemeristype).to eq "0".to_i
  end

  it 'element_number' do
      expect(tle.elementnumber).to eq " 475".to_i
  end

  it 'Inclination' do
      expect(tle.incliniation).to eq " 34.2682".to_f
  end

  it 'get xincl' do
      expect(tle.xincl).to eq 34.2682
  end

  it 'get omegao' do
      expect(tle.omegao).to eq 331.7664

  end

  it 'get xmo' do
      expect(tle.xmo).to eq 19.3264
  end

  it 'get xno' do
      expect(tle.xno).to eq 10.82419157
  end

  it 'right_ascension_ascendingnode' do
      expect(tle.rightascensionascendingnode).to eq "348.7242".to_f
  end

  it 'get Xnodeo' do
      expect(tle.xnodeo).to eq 348.7242
  end

  it 'eccentricity' do
      expect(tle.eccentricity).to eq "0.1859667".to_f
  end

  it 'get eo' do
      expect(tle.eo).to eq "0.1859667".to_f #* 1.0e-07
  end

  it 'argument_perigge' do
      expect(tle.argumentperigge).to eq "331.7664".to_f
  end

  it 'mean_anomaly' do
      expect(tle.meananomaly).to eq "19.3264".to_f
  end

  it 'mean_motion' do
      expect(tle.meanmotion).to eq "10.82419157".to_f
  end

  it 'revolution_number_epoch' do
      expect(tle.revolutionnumberepoch).to eq "41366".to_i
  end



end