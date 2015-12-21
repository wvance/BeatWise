source 'https://rubygems.org'

gem 'devise'
gem 'figaro'                        # HIDE KEYS FROM REPO
gem 'delayed_job_active_record'     # MOVES JOBS INTO BACKGROUND TASKS
# gem "twitter-bootstrap-rails"     # BOOTSTRAP GEM
gem 'bootstrap', '~> 4.0.0.alpha1'  # BOOTSTRAP ALPHA
gem "font-awesome-rails"
gem 'kaminari'                      # PAGINATION GEM
gem "chartkick"                     # SIMPLE CHARTING
gem 'groupdate'                     # NEEDED FOR GROUPING BY DATES
gem 'geocoder'                      # CONVERT LONG LAT TO LOCATION
gem 'httparty'
gem 'sidekiq'
gem 'sinatra', :require => nil
gem 'puma'
gem 'searchkick'

# ========================
# ==== API WRAPPERS ======
# ========================
gem 'twitter'                       # TWITTER API
# gem 'fitgem'                        # FITBIT API https://github.com/whazzmaster/fitgem
gem 'fitbit-api-client', require: 'fitbit'
gem 'instagram'
gem 'foursquare2'                   # FOURSQUARE API
gem 'github_api'                    # GITHUB API
gem 'koala'                         # FACEBOOK API
                                    # http://www.gotealeaf.com/blog/facebook-graph-api-using-omniauth-facebook-and-koala
gem "redd", "~> 0.7.0"


# ========================
# === OAUTH PROVIDERS ====
# ========================
# OMNIAUTH LOGIN: USED TO GET PERMISSION TO USER ACCOUNTS
# https://github.com/intridea/omniauth/wiki/List-of-Strategies
gem 'omniauth'                      # OMNIAUTH WITH DEVISE
gem 'omniauth-twitter'
gem 'omniauth-facebook'
gem 'omniauth-github'
# gem 'omniauth-fitbit'
gem 'omniauth-fitbit-oauth2'
gem 'omniauth-google-oauth2'
gem 'omniauth-foursquare'
gem 'omniauth-instagram'
gem 'omniauth-reddit', :git => 'git://github.com/wvance/omniauth-reddit.git'

# gem 'omniauth-linkedin'
# gem "linkedin-oauth2"
# gem 'omniauth-linkedin-oauth2'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.0'

# Use postgresql as the database for Active Record
gem 'pg'
gem 'rails_12factor', group: :production

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
gem 'jquery-turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

source 'https://rails-assets.org' do
  gem 'rails-assets-tether', '>= 1.1.0'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  # gem 'spring'
end

ruby "2.2.0"

