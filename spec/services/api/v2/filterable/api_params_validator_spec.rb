require 'rails_helper'

describe Api::V2::Filterable::ApiParamsValidator do
  before do
    @params = {
      variables: %w[o3 so2],
      statistical_measurements: %w[avg],
      time_min: '2020-01-01T00:00:00Z',
      time_max: '2020-01-02T00:00:00Z'
    }
  end

  describe 'valid' do
    it 'retun true if the params are valid' do
      expect(described_class.new(@params).valid?).to be true
    end

    it 'return false if invalid variables' do
      wrong_params = @params.dup.tap do |params|
        params[:variables] = %w[wrong incorrect]
      end
      initialized_class = described_class.new(wrong_params)
      expect(initialized_class.valid?).to be false
      error = initialized_class.errors.messages[:variables][0]
      expect(error).to eq('must be in the following list: so2, no2, pm10, pm2_5, co, o3')
    end

    it 'return false if invalid statistical measurements' do
      wrong_params = @params.dup.tap do |params|
        params[:statistical_measurements] = %w[maxxxx]
      end
      initialized_class = described_class.new(wrong_params)
      expect(initialized_class.valid?).to be false
      error = initialized_class.errors.messages[:statistical_measurements][0]
      expect(error).to eq('must be in the following list: avg, max, min')
    end

    it 'return false if range values format is incorrect' do
      wrong_params = @params.dup.tap do |params|
        params[:time_min] = '2020_02_03'
        params[:time_max] = '000-000000'
      end
      initialized_class = described_class.new(wrong_params)
      expect(initialized_class.valid?).to be false
      error = initialized_class.errors.messages[:range][0]
      expect(error).to eq('must be the following format: (?i-mx:[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z)')
    end

    it 'return false if invalid range' do
      wrong_params = @params.dup.tap do |params|
        params[:time_min] = '2020-01-03T00:00:00Z'
        params[:time_max] = '2020-01-02T00:00:00Z'
      end
      initialized_class = described_class.new(wrong_params)
      expect(initialized_class.valid?).to be false
      error = initialized_class.errors.messages[:range][0]
      expect(error).to eq('time_max must be higher to time_min')
    end

    it 'not allow geom and possitions params at the same time' do
      wrong_params = @params.dup.tap do |params|
        params[:stations] = ['aq_distrito_telefonica']
        params[:geom] = '{"type":"Polygon","coordinates":[[[-3.63289587199688,40.56439731247202],[-3.661734983325005,40.55618117044514],[-3.66310827434063,40.53583209794804],[-3.6378740519285206,40.52421992151271],[-3.6148714274168015,40.5239589506112],[-3.60543005168438,40.547181381686634],[-3.63289587199688,40.56439731247202]]]}'
      end
      initialized_class = described_class.new(wrong_params)
      expect(initialized_class.valid?).to be false
      error = initialized_class.errors.messages[:stations][0]
      expect(error).to eq('incompatible params, choose only one: stations, geom')
    end
  end
end
