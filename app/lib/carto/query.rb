module Carto
  class Query

    TABLES = {
      measurements: 'aasuero.test_airquality_measurements',
      stations: 'aasuero.test_airquality_stations',
      grid: 'aasuero.esp_grid_1km_demographics'
    }.freeze

    def initialize(params)
      @params = params.symbolize_keys
    end

    private

    def variable_names
      variables = @params[:variables] || Carto::Utils.variables
      measurements = @params[:statistical_measurements] || Carto::Utils.statistical_measurements

      variables.map do |variable|
        measurements.map do |measurement|
          "#{measurement}_#{variable}"
        end
      end.flatten
    end

    def query_variables
      result = variable_names.map do |variable|
        opts = variable.split('_')
        "#{opts[0].upcase}(#{TABLES[:measurements]}.#{opts[1]}) as #{variable}"
      end.flatten.join(', ')

      result + ", #{TABLES[:measurements]}.station_id"
    end

    def query_filters
      result = ''
      result += with_geom if @params[:geom]

      return result unless @params.keys.map { |parm| %i[time_max time_min stations].include? parm }.any?

      result += (@params[:geom] ? 'AND' : 'WHERE')
      (result += range_filter) if @params[:time_min]
      (result += "#{@params[:time_min] ? 'AND' : ''} #{stations_filter}") if @params[:stations]

      result
    end

    def range_filter
      " #{TABLES[:measurements]}.timeinstant BETWEEN '#{@params[:time_min]}' AND '#{@params[:time_max]}'"
    end

    def stations_filter
      stations = @params[:stations].map { |station| "'#{station}'" }.join(',')

      "#{TABLES[:measurements]}.station_id IN (#{stations})"
    end

    def with_geom
      "LEFT JOIN #{TABLES[:stations]} ON #{TABLES[:measurements]}.station_id = #{TABLES[:stations]}.station_id WHERE ST_Intersects(#{geom_collection}::geography, #{TABLES[:stations]}.the_geom)"
    end

    def geom_collection
      polygon_points = JSON.parse(@params[:geom])['coordinates']
                           .flatten(1)
                           .map { |coords| coords.join(' ') }
                           .join(',')

      "'GEOMETRYCOLLECTION(POLYGON((#{polygon_points})))'"
    end

    def step
      @params[:step] || 'day'
    end
  end
end
