module RPredict
  module Satellite
    class TLEImportFromFile < TLEImport

      def initialize(sourse)
        super
      end
      def import_TLE()
        super
        if File.exist? source

          newsat = true
          name = ""
          line1 = ""
          File.foreach(source).with_index do |line|

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
        end
        @satellites
      end
    end
  end
end

