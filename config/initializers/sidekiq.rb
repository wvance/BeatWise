require 'sidekiq/web'

Sidekiq.configure_server do |config|
  ActiveRecord::Base.configurations[Rails.env.to_s]['pool'] = 30
end
