require 'rails_helper'

describe Api::V2::Filterable::GeometryValidator do
  before do
    @polygon = '{"type":"Polygon","coordinates":[[[-3.63289587199688,40.56439731247202],[-3.661734983325005,40.55618117044514],[-3.66310827434063,40.53583209794804],[-3.6378740519285206,40.52421992151271],[-3.6148714274168015,40.5239589506112],[-3.60543005168438,40.547181381686634],[-3.63289587199688,40.56439731247202]]]}'
  end

  describe 'valid?' do
    it 'retun true if the polygon geometry is valid' do
      expect(described_class.new(@polygon).valid?).to be true
    end

    it 'return false if the polygon type is not valid' do
      wrong_polygon = @polygon.dup.sub! 'Polygon', 'Wrong'
      expect(described_class.new(wrong_polygon).valid?).to be false
    end

    it 'return false if coordinates polygon is not valid' do
      wrong_polygon = @polygon.dup.sub! '-3.63289587199688', '"xxxxxx"'
      expect(described_class.new(wrong_polygon).valid?).to be false
    end
  end
end
