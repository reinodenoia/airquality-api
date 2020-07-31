require 'rails_helper'

describe Carto::Query do

  before :all do
    TABLES = {
      measurements: 'aasuero.test_airquality_measurements',
      stations: 'aasuero.test_airquality_stations',
      grid: 'aasuero.esp_grid_1km_demographics'
    }.freeze
  end

  describe 'build' do
    it 'return a query depending on params1' do
      params1 = {
        variables: %w[so2],
        statistical_measurements: %w[avg min max],
        geom: '{"type":"Polygon","coordinates":[[[-3.63289587199688,40.56439731247202],[-3.661734983325005,40.55618117044514],[-3.66310827434063,40.53583209794804],[-3.6378740519285206,40.52421992151271],[-3.6148714274168015,40.5239589506112],[-3.60543005168438,40.547181381686634],[-3.63289587199688,40.56439731247202]]]}'
      }

      expected =
        <<-SQL
          SELECT
            sub.station_id,
            sub.avg_so2, sub.min_so2, sub.max_so2,
            #{TABLES[:grid]}.population as population
          FROM (
            SELECT AVG(#{TABLES[:measurements]}.so2) as avg_so2, MIN(#{TABLES[:measurements]}.so2) as min_so2, MAX(#{TABLES[:measurements]}.so2) as max_so2, #{TABLES[:measurements]}.station_id
            FROM #{TABLES[:measurements]}
            LEFT JOIN #{TABLES[:stations]} ON #{TABLES[:measurements]}.station_id = #{TABLES[:stations]}.station_id WHERE ST_Intersects('GEOMETRYCOLLECTION(POLYGON((-3.63289587199688 40.56439731247202,-3.661734983325005 40.55618117044514,-3.66310827434063 40.53583209794804,-3.6378740519285206 40.52421992151271,-3.6148714274168015 40.5239589506112,-3.60543005168438 40.547181381686634,-3.63289587199688 40.56439731247202)))'::geography, #{TABLES[:stations]}.the_geom)
            GROUP BY #{TABLES[:measurements]}.station_id
          ) sub
          LEFT JOIN #{TABLES[:stations]} AS stations_join
          ON sub.station_id = stations_join.station_id
          LEFT JOIN #{TABLES[:grid]}
          ON ST_Intersects(#{TABLES[:grid]}.the_geom, stations_join.the_geom)
        SQL

      initialized_class = described_class.new(params1)
      expect(initialized_class.build.gsub(/[[:space:]]/, '')).to eq(expected.gsub(/[[:space:]]/, ''))
    end

    it 'return a query depending on params2' do
      params2 = {
        variables: %w[so2 co],
        statistical_measurements: %w[avg],
        stations: ['aq_jaen']
      }

      expected =
        <<-SQL
          SELECT
            sub.station_id,
            sub.avg_so2, sub.avg_co,
            #{TABLES[:grid]}.population as population
          FROM (
            SELECT AVG(#{TABLES[:measurements]}.so2) as avg_so2, AVG(#{TABLES[:measurements]}.co) as avg_co, #{TABLES[:measurements]}.station_id
            FROM #{TABLES[:measurements]}
            WHERE #{TABLES[:measurements]}.station_id IN ('aq_jaen')
            GROUP BY #{TABLES[:measurements]}.station_id
          ) sub
          LEFT JOIN #{TABLES[:stations]} AS stations_join
          ON sub.station_id = stations_join.station_id
          LEFT JOIN #{TABLES[:grid]}
          ON ST_Intersects(#{TABLES[:grid]}.the_geom, stations_join.the_geom)
        SQL

      initialized_class = described_class.new(params2)
      expect(initialized_class.build.gsub(/[[:space:]]/, '')).to eq(expected.gsub(/[[:space:]]/, ''))
    end

    it 'return a query depending on params3' do
      params3 = {
        variables: %w[so2 co],
        statistical_measurements: %w[avg],
        time_min: '2016-10-02T01:45:00Z',
        time_max: '2016-10-22T01:45:00Z'
      }

      expected =
        <<-SQL
          SELECT
            sub.station_id,
            sub.avg_so2, sub.avg_co,
            #{TABLES[:grid]}.population as population
          FROM (
            SELECT AVG(#{TABLES[:measurements]}.so2) as avg_so2, AVG(#{TABLES[:measurements]}.co) as avg_co, #{TABLES[:measurements]}.station_id
            FROM #{TABLES[:measurements]}
            WHERE #{TABLES[:measurements]}.timeinstant BETWEEN '2016-10-02T01:45:00Z' AND '2016-10-22T01:45:00Z'
            GROUP BY #{TABLES[:measurements]}.station_id
          ) sub
          LEFT JOIN #{TABLES[:stations]} AS stations_join
          ON sub.station_id = stations_join.station_id
          LEFT JOIN #{TABLES[:grid]}
          ON ST_Intersects(#{TABLES[:grid]}.the_geom, stations_join.the_geom)
        SQL

      initialized_class = described_class.new(params3)
      expect(initialized_class.build.gsub(/[[:space:]]/, '')).to eq(expected.gsub(/[[:space:]]/, ''))
    end

    it 'return a query depending on params4' do
      params4 = {
        variables: %w[so2],
        time_min: '2016-10-02T01:45:00Z',
        time_max: '2016-10-22T01:45:00Z'
      }

      expected =
        <<-SQL
          SELECT
            sub.station_id,
            sub.avg_so2, sub.max_so2, sub.min_so2,
            #{TABLES[:grid]}.population as population
          FROM (
            SELECT AVG(#{TABLES[:measurements]}.so2) as avg_so2, MAX(#{TABLES[:measurements]}.so2) as max_so2, MIN(#{TABLES[:measurements]}.so2) as min_so2, #{TABLES[:measurements]}.station_id
            FROM #{TABLES[:measurements]}
            WHERE #{TABLES[:measurements]}.timeinstant BETWEEN '2016-10-02T01:45:00Z' AND '2016-10-22T01:45:00Z'
            GROUP BY #{TABLES[:measurements]}.station_id
          ) sub
          LEFT JOIN #{TABLES[:stations]} AS stations_join
          ON sub.station_id = stations_join.station_id
          LEFT JOIN #{TABLES[:grid]}
          ON ST_Intersects(#{TABLES[:grid]}.the_geom, stations_join.the_geom)
        SQL

      initialized_class = described_class.new(params4)
      expect(initialized_class.build.gsub(/[[:space:]]/, '')).to eq(expected.gsub(/[[:space:]]/, ''))
    end
  end
end
