module Api
  module V2
    module Filterable
      class ApiParamsValidator
        include ActiveModel::Validations
        attr_reader :time_min, :time_max, :geom, :statistical_measurements,
                    :variables, :stations, :step

        VALUES = {
          statistical_measurements: %w[avg max min],
          variables: %w[so2 no2 pm10 pm2_5 co o3],
          step: %w[week day hour]
        }.freeze

        TIME_REGEXP = /[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z/i.freeze

        validates_inclusion_of :step,
                               in: VALUES[:step],
                               allow_blank: true,
                               message: "must be one from the following list: #{VALUES[:step].join(', ')}"

        validate :valid_range

        validate :valid_arrays

        validate :valid_stations

        validate :valid_geom

        def initialize(params = {})
          params.each do |param|
            instance_variable_set("@#{param[0]}", param[1])
          end
        end

        private

        def valid_range
          range_values = [@time_min, @time_max].compact
          return if range_values.blank?

          return errors[:range] << 'must be two parameters: time_min and time_max' if range_values.one?

          return errors[:range] << "must be the following format: #{TIME_REGEXP}" unless valid_dates_values(range_values)

          utc_values = range_values.map { |val| val.to_datetime.utc }
          return if utc_values[1] > utc_values[0]

          errors[:range] << 'time_max must be higher to time_min'
        end

        def valid_dates_values(range_values)
          range_values.map do |val|
            TIME_REGEXP.match?(val)
          end.all?
        end

        def valid_arrays
          %i[statistical_measurements variables].each do |param|
            instance_variable = "@#{param}".to_sym
            next unless instance_variables.include? instance_variable

            valid = valid_array_values(instance_variable_get(instance_variable.to_s), VALUES[param])
            next if valid

            errors[param] << "must be in the following list: #{VALUES[param].join(', ')}"
          end
        end

        def valid_array_values(param_values, valid_values)
          param_values.map { |val| valid_values.include? val }.all?
        end

        def valid_stations
          both_params = %i[stations geom].map { |param| instance_variables.include? "@#{param}".to_sym }.all?
          return unless both_params

          errors[:stations] << 'incompatible params, choose only one: stations, geom'
        end

        def valid_geom
          return unless @geom

          valid = GeometryValidator.new(@geom).valid?
          errors[:geom] << 'must be a valid geometry polygon' unless valid
        end
      end
    end
  end
end
