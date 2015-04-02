require 'spec_helper'

describe RPredict::DateUtil  do

  let(:monthNum) { 12 }
  let(:dayNum) {31}
  let(:yearNum) {79}
  let(:year) {2012.0}
  let(:mon) {8.0}
  let(:day) {22.0}
  let(:hr) {17.0}
  let(:minute) {0.0}
  let(:sec) {30.000011623289495}
  let(:jd) {2456162.2086805557}

  let(:epoch  ) {"06052.34767361"}

  it  'get DayNum' do
     expect(RPredict::DateUtil.dayNum(monthNum,dayNum,yearNum)).to eq 0.0
  end

end