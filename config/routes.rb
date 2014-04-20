Pfe::Application.routes.draw do

  devise_for :users, :controllers => {:registrations => "users/registrations"}

  resources :categories, :tracks, :forums, :teams, :groups, :happenings, :users

  get 'users/:id/activities' => 'activities#index'

  resources :forums do
    resources :comments
    resources :favorites
  end

  resources :happenings do
    resources :users, :controller => 'happeningsuser', :only => [:new, :create, :destroy]
    resources :tracks, :controller => 'happeningtracks', :only => [:new, :create, :destroy]
  end

  resources :happenings do
    resources :user_statuses
    resources :favorites
  end

  resources :tracks do
    resources :favorites
  end

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
end
