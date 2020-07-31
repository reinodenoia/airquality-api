module Carto
  class MeasurementsQuery < Query

    def build
      <<-SQL
        SELECT
          sub.station_id,
          #{variable_names.map { |variable| "sub.#{variable}" }.join(', ')}#{variable_names.any? ? ',' : ''}
          #{TABLES[:grid]}.population as population
        FROM (
          SELECT #{query_variables}
          FROM #{TABLES[:measurements]}
          #{query_filters}
          GROUP BY #{TABLES[:measurements]}.station_id
        ) sub
        LEFT JOIN #{TABLES[:stations]} AS stations_join
        ON sub.station_id = stations_join.station_id
        LEFT JOIN #{TABLES[:grid]}
        ON ST_Intersects(#{TABLES[:grid]}.the_geom, stations_join.the_geom)
      SQL
    end

  end
end
