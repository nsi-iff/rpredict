require 'open-uri'
module RPredict
  module Satellite
    class TLEImportFromURL < TLEImport

      def initialize(source)
        super
      end
      def import_TLE()
        uriReader = open(@source).readlines
        super uriReader
      end
    end
  end
end
