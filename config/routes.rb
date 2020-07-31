Rails.application.routes.draw do
  namespace :api, defaults: { format: 'json' } do
    namespace :v2 do
      resources :measurements, only: %i[index]
      resources :timeseries, only: %i[index]
    end
  end
end
