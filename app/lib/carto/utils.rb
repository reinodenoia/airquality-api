module Carto
  module Utils
    def self.statistical_measurements
      %w[avg max min]
    end

    def self.variables
      %w[so2 no2 pm10 pm2_5 co o3]
    end

    def self.step
      %w[week day hour]
    end
  end
end
