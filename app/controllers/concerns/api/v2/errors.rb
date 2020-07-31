module Api
  module V2
    #
    # Raise Exceptions from controller to use Api::V2 Errors
    #
    module Errors
      extend ActiveSupport::Concern

      ERRORS = {
        bad_request: {
          http_code: 400
        },
        auth_error: {
          http_code: 401
        },
        forbidden: {
          http_code: 403
        },
        not_found: {
          http_code: 404
        },
        invalid_parameter: {
          http_code: 422
        }
      }.freeze

      ERRORS.each { |error, _| const_set error.to_s.camelize, Class.new(StandardError) }

      included do
        ERRORS.each do |error, val|
          error = error.to_s.camelize

          rescue_from "Api::V2::Errors::#{error}".constantize do |exception|
            render(
              json: {
                error: { message: "#{error}: #{exception}" }
              },
              status: val[:http_code]
            )
          end
        end
      end
    end
  end
end
