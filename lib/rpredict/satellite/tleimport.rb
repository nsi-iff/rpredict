module RPredict
  module Satellite
    class TLEImport

      attr_accessor :source, :satellites, :lastflush

      def initialize(source)

        @satellites = []
        @lastflush = Time.now.to_f

        if not source.is_a? String
          raise  RPredict::Exceptions::GeneralException,  'Source is not a String'
        end

        @source  = source

      end

      def import_TLE(reader)
        newsat = true
        name = ""
        line1 = ""

        reader.each_with_index do |line|

          case line[0]
            when "1"
              line1 = line
            when "2"

              satellite = RPredict::Satellite.new(name,line1,line)

              satellite.tle.mfestart  = line[70...81].to_f
              satellite.tle.mfeend    = line[81...91].to_f
              satellite.tle.deltatime = line[91..105].to_f

              @satellites << satellite
            else
              name = line
          end

        end

        @satellites

      end

    end
  end
end
