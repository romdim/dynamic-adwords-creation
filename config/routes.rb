Rails.application.routes.draw do
  get "home/index"

  resources :campaigns, only: [:index, :create, :new, :destroy], param: :campaign_id do
    member do
      resources :ad_groups, param: :ad_group_id do
        member do
          resources :ads
        end
      end
    end
  end

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
