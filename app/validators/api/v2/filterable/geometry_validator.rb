module Api
  module V2
    module Filterable
      class GeometryValidator

        TYPE = 'Polygon'.freeze

        def initialize(polygon)
          @polygon = JSON.parse(polygon)
        end

        def valid?
          valid_type && valid_coordinates
        end

        private

        def valid_type
          @polygon['type'] == TYPE
        end

        def valid_coordinates
          coordinates = @polygon['coordinates']
          return false if coordinates.blank?

          valid_format = coordinates[0].map { |coord| valid_coordinate(coord) }.all?
          valid_data = coordinates[0].first == coordinates[0].last

          valid_format && valid_data
        end

        def valid_coordinate(coord)
          return false if coord.size != 2

          valid_lat_coord = coord[0].is_a?(Float) ? (coord[0] >= -90 && coord[0] <= 90) : false
          valid_lng_coord = coord[1].is_a?(Float) ? (coord[1] >= -180 && coord[1] <= 180) : false
          valid_lat_coord && valid_lng_coord
        end
      end
    end
  end
end
