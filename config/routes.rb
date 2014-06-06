Pfe::Application.routes.draw do

  devise_for :users, :controllers => {:registrations => "users/registrations", :omniauth_callbacks => "users/omniauth_callbacks"}

  resources :categories, :teams

  get 'users/:id/activities' => 'activities#index'

  get 'tracks/:id/download' => 'tracks#download', as: :download_track

  resources :users do
    resources :groups, :only => [:index]
    resources :tracks, :only => [:index]
    resources :happenings, :only => [:index]
    resources :favorites, :only => [:index]
  end

  resources :forums do
    resources :comments
    resources :favorites
  end

  resources :groups do
    resources :groupers, :only => [:index, :update, :create, :destroy]
    resources :happenings
    resources :tracks
  end

  resources :happenings do
    resources :tracks, :only => [:new, :create, :destroy]
    resources :user_statuses, :only => [:index, :create, :destroy]
    resources :favorites, :only => [:index, :create, :destroy]
    resources :forums, :only => [:new, :create, :destroy]
    resources :images, :only => [:new, :create, :destroy]
  end

  resources :tracks, only: [:index, :show, :new, :create, :destroy] do
    resources :favorites, :only => [:index, :create, :destroy]
    resources :forums, :only => [:new, :create, :destroy]
    resources :images, :only => [:new, :create, :destroy]
  end

  get 'dashboard' => 'users#dashboard', as: :user_dashboard

  root :to =>  'welcome#index'

  get 'conversations/new/:id' => 'conversations#new', as: :new_user_conversation

  get 'conversations/trash' => 'conversations#indextrash', as: :indextrash_conversation

  resources :conversations, only: [:index, :show, :new, :create, :delete] do
    member do
      post :reply
      post :trash
      post :untrash
      delete :delete
    end
  end

  %w( 404 422 500 ).each do |code|
    get code, :to => "errors#show", :code => code
  end
end
