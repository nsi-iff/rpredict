module RPredict
  module Satellite
    class TLEImportFromFile < TLEImport

      def initialize(sourse)
        super
      end
      def import_TLE()
        uriReader = open(@source).readlines
        super uriReader
      end
    end
  end
end
