module RPredict
  module Satellite
    class TLEImport

      attr_accessor :source, :satellites

      def initialize(source)

        @satellites = []
        @source     = source

      end

      def import_TLE()

        if not @source.is_a? String
          puts 'Source is not a String'
        end
      end

    end
  end
end
