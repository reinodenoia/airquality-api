module Api
  module V2
    class MeasurementsController < ApplicationController

      def index
        data = Carto::Api.new.request(query)
        render_data(beautify(data))
      end

      private

      def filterable_params
        params.permit(common_params)
      end

      def query
        Carto::MeasurementsQuery.new(filterable_params.to_h).build.delete!("\n")
      end

      def beautify(data)
        data.tap do |dat|
          dat['rows'].map! do |row|
            measurements = {}

            Carto::Utils.statistical_measurements.each do |measurement|
              row.except(%w[station_id population])
                 .select { |k, _| k[/#{measurement}/] }
                 .tap do |hash|
                next unless hash.keys.any?
                measurements.merge!(measurement.to_s => hash.map { |k, _| { "#{k.to_s.split('_')[1]}" => hash[k.to_s] } })
              end
            end

            {
              station_id: row['station_id'],
              population: row['population'],
              measurements: measurements
            }
          end
        end
      end
    end
  end
end
