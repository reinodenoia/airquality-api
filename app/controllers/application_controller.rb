class ApplicationController < ActionController::API
  include Api::V2::Errors

  private

  def render_data(data)
    render json: { data: data }
  end
end
