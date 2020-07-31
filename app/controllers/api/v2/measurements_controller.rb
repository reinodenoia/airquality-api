module Api
  module V2
    class MeasurementsController < ApplicationController
      before_action :check_params

      def index
        data = Carto::Api.new.request(query)
        render_data(beautify(data))
      end

      private

      def filterable_params
        params.permit(
          :time_min, :time_max, :geom,
          statistical_measurements: [], variables: [], stations: []
        )
      end

      def check_params
        validator = Filterable::ApiParamsValidator.new(filterable_params.to_h)
        return if validator.valid?

        error = validator.errors.messages.to_a
                         .map { |err| "#{err.first.upcase}: #{err.last[0]}" }
                         .join('; ')
        raise InvalidParameter, error
      end

      def query
        Carto::Query.new(filterable_params.to_h).build.delete!("\n")
      end
    end
  end
end
