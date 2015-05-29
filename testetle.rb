require 'rpredict'

tleimportfromfile = RPredict::Satellite::TLEImportFromFile.new("TLE_Constelacao.tle")

p tleimportfromfile.source
p tleimportfromfile.import_TLE.size
p tleimportfromfile.satellites.size

