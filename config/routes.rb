Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check

  root "pages#home"

  resources :qr_codes, only: [ :create ], param: :short_code do
    member do
      get "preview", action: "preview"
    end
  end
end
