Rails.application.routes.draw do
  resources :ad_groups do
    member do
      resources :ads
    end
  end
  get "home/index"

  get "campaign/index"
  get "campaign/create"

  get "account/index"
  get "account/input"
  get "account/select"

  get "login/prompt"
  get "login/callback"
  get "login/logout"

  get "report/index"
  post "report/get"

  root :to => "home#index"
end
