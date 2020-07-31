module Carto
  class Api
    CONTENT_TYPE = 'application/json'.freeze

    def initialize; end

    def request(query)
      url = "#{host}/api/v#{version}/sql?q=#{query}"

      response = HTTParty.get(url, headers: { 'Content-type' => CONTENT_TYPE })

      raise "Api::V2::Errors::#{response.message.gsub!(/\s+/, '')}" unless response.success?

      JSON.parse(response.body)
    end

    private

    def api_settings
      APP_CONFIG[:carto][:api]
    end

    def version
      api_settings[:version]
    end

    def host
      api_settings[:host]
    end
  end
end
