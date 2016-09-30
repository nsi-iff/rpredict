require 'spec_helper'

describe RPredict::Satellite::TLEImportFromURL  do

  let(:source) {'http://www.celestrak.com/NORAD/elements/stations.txt'}
  let(:tleFile) { RPredict::Satellite::TLEImportFromURL.new(source)}

  it 'get Size URL TLE  ' do
    expect(tleFile.import_TLE().size).to eq 50
  end

end
