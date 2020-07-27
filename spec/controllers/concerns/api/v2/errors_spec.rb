require 'rails_helper'

describe Api::V2::MeasurementsController do
  describe 'GET index' do
    ERRORS = {
      'AuthError' => { http: 401 },
      'Forbidden' => { http: 403 },
      'NotFound' => { http: 404 },
      'InvalidParameter' => { http: 422 }
    }.freeze

    ERRORS.each do |name, codes|
      context "when #{name} error" do
        subject! do
          allow_any_instance_of(described_class).to receive(:index).and_raise(
            "Api::V2::Errors::#{name}".constantize
          )

          get :index
        end

        it "Response has #{codes[:http]} HTTP code" do
          expect(response.code.to_i).to eq codes[:http]
        end

        it "Response has #{codes[:code]} code" do
          expect(JSON.parse(response.body)['error']['code']).to(
            eq codes[:code]
          )
        end
      end
    end
  end
end
