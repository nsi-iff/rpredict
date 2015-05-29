require 'spec_helper'

describe RPredict::Satellite::TLEImportFromFile  do

  let(:source) {"SGP4-VER.TLE"}
  let(:tleFile) { RPredict::Satellite::TLEImportFromFile.new(source)}

  it 'get Size File TLE  ' do
    expect(tleFile.import_TLE().size).to eq 33
  end

end