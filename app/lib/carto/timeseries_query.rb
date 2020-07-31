module Carto
  class TimeseriesQuery < Query

    def build
      <<-SQL
        SELECT *
        FROM (
          SELECT #{TABLES[:measurements]}.station_id as station_id, generate_series(MIN(#{TABLES[:measurements]}.timeinstant), MAX(#{TABLES[:measurements]}.timeinstant), '1 #{step}') as time
          FROM #{TABLES[:measurements]}
          #{query_filters}
          GROUP BY #{TABLES[:measurements]}.station_id
          ) sub
        CROSS JOIN LATERAL (
          SELECT #{query_variables}
          FROM #{TABLES[:measurements]}
          WHERE #{TABLES[:measurements]}.station_id = sub.station_id
          AND timeinstant >= sub.time
          AND timeinstant < sub.time - -(interval '1 #{step}')::interval
          GROUP BY #{TABLES[:measurements]}.station_id
        ) avg
        ORDER BY avg.station_id
      SQL
    end

  end
end
