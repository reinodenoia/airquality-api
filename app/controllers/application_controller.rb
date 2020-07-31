class ApplicationController < ActionController::API
  include Api::V2::Errors
  before_action :check_params

  private

  def render_data(data)
    render json: { data: data }
  end

  def check_params
    validator = Api::V2::Filterable::ApiParamsValidator.new(filterable_params.to_h)
    return if validator.valid?

    error = validator.errors.messages.to_a
                     .map { |err| "#{err.first.upcase}: #{err.last[0]}" }
                     .join('; ')
    raise InvalidParameter, error
  end

  def common_params
    [:time_min, :time_max, :geom,
     statistical_measurements: [], variables: [], stations: []]
  end
end
