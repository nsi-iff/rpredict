require 'spec_helper'

describe RPredict::Exceptions  do
  it 'get SatelliteException ' do
    expect { raise  RPredict::Exceptions::SatelliteException, 'this message exactly'}.
      to raise_error('this message exactly')
  end

  it 'get TleException ' do
    expect { raise  RPredict::Exceptions::TleException, 'this message exactly'}.
      to raise_error('this message exactly')
  end

  it 'get URLException ' do
    expect { raise  RPredict::Exceptions::URLException, 'this message exactly'}.
      to raise_error('this message exactly')
  end

  it 'get GeneralException ' do
    expect { raise  RPredict::Exceptions::GeneralException, 'this message exactly'}.
      to raise_error('this message exactly')
  end

  it 'get ObserverException ' do
    expect { raise  RPredict::Exceptions::ObserverException, 'this message exactly'}.
      to raise_error('this message exactly')
  end

  it 'get UnknownSatellite ' do
    expect { raise  RPredict::Exceptions::UnknownSatellite, 'this message exactly'}.
      to raise_error('this message exactly')
  end

end
