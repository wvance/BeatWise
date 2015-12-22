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
  get '/channels/foursquare',       to: 'channel#foursquare',                   as: :foursquare
  get '/channels/instagram',        to: 'channel#instagram',                    as: :instagram
  get '/channels/github',           to: 'channel#github',                       as: :github
  get '/channels/facebook',         to: 'channel#facebook',                     as: :facebook
  get '/channels/reddit',           to: 'channel#reddit',                       as: :reddit
  get '/channles/spotify',          to: 'channel#spotify',                      as: :spotify

  # get '/content/index',             to: 'content#index',                        as: :content_index
  get '/all_facebook',              to: 'content#get_facebook_all',             as: :all_facebook
  get '/recent_fitbit_activities',  to: 'content#get_fitbit_recent_activitity', as: :recent_fitbit_activities
  get '/all_foursquare',            to: 'content#get_foursquare_all',           as: :all_foursquare
  get '/get_github_repos',          to: 'content#get_github_repos',             as: :get_github_repos
  get '/twitter_tweets',            to: 'content#get_twitter_tweets',           as: :twitter_tweets
  get '/fitbit_heart',              to: 'content#get_fitbit_daily_heart_rate',  as: :fitbit_heart
  get '/instagram_photos',          to: 'content#get_instagram_photos',         as: :instagram_photos
  get '/fitbit_all_data',           to: 'content#fitbit_all_data',              as: :fitbit_all_data
  get '/reddit_all_data',           to: 'content#reddit_all_data',              as: :reddit_all_data
  get '/spottify_all_data',         to: 'content#spotify_all_data',             as: :spotify_all_data

  get 'welcome/index',              to: 'welcome#index',                        as: :welcome

  # You can have the root of your site routed with "root"
  root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
