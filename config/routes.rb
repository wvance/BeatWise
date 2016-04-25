Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".
  resources :content
  resources :notifications do
    collection do
      post :mark_as_read
    end
  end

  resources :channel do

  end
  devise_for :users, :controllers => { omniauth_callbacks: 'omniauth_callbacks' }
  match '/users/:id/finish_signup' => 'users#finish_signup', via: [:get, :patch], :as => :finish_signup

  match '/sign_out_provider/:provider' => 'users#sign_out_provider', via: [:get], :as => :sign_out_provider

  get '/channels',                  to: 'channel#index',                        as: :channels
  get '/channels/twitter',          to: 'channel#twitter',                      as: :twitter
  get '/channels/fitbit',           to: 'channel#fitbit',                       as: :fitbit
  get '/channels/fitbitChart',      to: 'channel#fitbitChart',                  as: :fitbitChart
  # get '/content/index',             to: 'content#index',                        as: :content_index
  get '/recent_fitbit_activities',  to: 'content#get_fitbit_recent_activitity', as: :recent_fitbit_activities
  get '/fitbit_heart',              to: 'content#get_fitbit_daily_heart_rate',  as: :fitbit_heart
  get '/fitbit_all_data',           to: 'content#fitbit_all_data',              as: :fitbit_all_data
  get '/twitter_tweets',            to: 'content#get_twitter_tweets',           as: :twitter_tweets
  get '/fitbit_intra_heart',        to: 'content#get_fitbit_intraday_heartbeat', as: :fitbit_intra_heart

  get 'welcome/index',              to: 'welcome#index',                        as: :welcome

  # You can have the root of your site routed with "root"
  root 'welcome#index'

end
