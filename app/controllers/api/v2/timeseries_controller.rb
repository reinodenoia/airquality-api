module Api
  module V2
    class TimeseriesController < ApplicationController

      def index
        data = Carto::Api.new.request(query)
        render_data(beautify(data))
      end

      private

      def filterable_params
        params.permit(common_params << :step)
      end

      def query
        Carto::TimeseriesQuery.new(filterable_params.to_h).build.delete!("\n")
      end

      def beautify(data)
        data.tap do |dat|
          result = dat['rows'].group_by { |hash| hash['station_id'] }.map do |_, values|
            timeseries = []

            values.each do |val|
              measurements = {}
              Carto::Utils.statistical_measurements.each do |measurement|
                val.except(%w[station_id time])
                    .select { |k, _| k[/#{measurement}/] }
                    .tap do |hash|
                  next unless hash.keys.any?
                  measurements.merge!(measurement.to_s => hash.map { |k, _| { "#{k.to_s.split('_')[1]}" => hash[k.to_s] } })
                end

                timeseries << {
                  time: val['time'],
                  measurements: measurements
                }
              end
            end

            {
              station_id: values.first['station_id'],
              timeseries: timeseries
            }
          end
          dat['rows'] = result
        end
      end
    end
  end
end



# {
#   "station_id": "aq_nevero",
#   "population": 5083.06591796875,
#   "timeseries": [
#     {
#       "time": '2020-2-2',
#       "measurements": {
#         "avg": [
#             {
#                 "o3": 54.0858550705087
#             },
#             {
#                 "so2": 17.8859773944261
#             }
#         ],
#         "max": [
#             {
#                 "o3": 104.837489918279
#             },
#             {
#                 "so2": 69.7703034454513
#             }
#         ],
#         "min": [
#             {
#                 "o3": 8.41106976347284
#             },
#             {
#                 "so2": 3.21502016300047
#             }
#         ]
#       }
#     },

#   ]
  
#   }
# }




