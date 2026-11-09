Rails.application.routes.draw do
  get "/health", to: "health#show"

  namespace :api do
    namespace :v1 do
      get "/csrf", to: "sessions#csrf"
      resource :session, only: %i[create destroy]
      get "/me", to: "me#show"
      get "/dashboard", to: "dashboard#show"
      resources :households
      resources :clients do
        resources :activities, only: %i[index create]
      end
      resources :opportunities
    end
  end
end
