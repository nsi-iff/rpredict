module RPredict
  module Test
    module Resources
      def resource(name)
        File.open(File.expand_path(
          File.join(File.dirname(__FILE__), '..', 'resources', name)))
      end

      def sgp4_tle
        resource('sgp4-ver.tle')
      end

      def stations
        resource('stations.txt')
      end

    end
  end
end