Rails.application.routes.draw do
  # Devise (認証)
  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }

  # ルート
  root "tasks#index"

  # タスク管理
  resources :tasks do
    resources :milestones, only: [:create, :update, :destroy] do
      member do
        patch :toggle
      end
    end
    member do
      patch :complete
    end
  end

  # 決済
  resources :payments, only: [:new, :create, :index] do
    collection do
      get :card_status
    end
  end

  # Stripe Webhook
  post "/webhooks/stripe", to: "webhooks#stripe"

  # ヘルスチェック
  get "up" => "rails/health#show", as: :rails_health_check
end
