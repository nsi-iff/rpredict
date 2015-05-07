require 'spec_helper'

describe RPredict::DateUtil  do

  let(:monthNum) { 12 }
  let(:dayNum) {31}
  let(:yearNum) {79}
  let(:year) {2015}
  let(:mon) {4}
  let(:day) {28}
  let(:hr) {14}
  let(:minute) {3}
  let(:sec) {20}
  let(:jd) {2457141.2106481483}
  let(:dt) {DateTime.new(year, mon, day, hr+3, minute, sec)}


  let(:epoch  ) {"06052.34767361"}

  it  'get DayNum' do
     expect(RPredict::DateUtil.dayNum(monthNum,dayNum,yearNum)).to eq 0.0
  end

  it 'Test JulianDay From DateTime' do
    expect(RPredict::DateUtil.julianday_DateTime(dt)).to eq jd
  end

  it 'Test InvJulianDay From DateTime' do
    expect(RPredict::DateUtil.invjulianday_DateTime(jd).year).to eq dt.year
  end

  it 'Test JulianDay From String' do
    expect(RPredict::DateUtil.julianday(year, mon, day, hr, minute, sec)).to eq jd
  end

  it 'Test InvJulianDay From String' do
    expect(RPredict::DateUtil.invjulianday(jd)[0]).to eq year
  end

  it 'Test Day' do
     expect(RPredict::DateUtil.day("2015-04-28 14:03:20")).to eq jd
  end



end