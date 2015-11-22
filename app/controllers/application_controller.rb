class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # THESE ARE USED TO SET UP THE CLIENTS, ONLY IF A PROVIDER IS PRESENT!
  before_action :set_twitter_client
  before_action :set_foursquare_client
  before_action :set_fitbit_client
  before_action :set_facebook_client
  before_action :set_github_client

  def ensure_signup_complete
    # Ensure we don't go into an infinite loop
    return if action_name == 'finish_signup'

    # Redirect to the 'finish_signup' page if the user
    # email hasn't been verified yet
    if current_user && !current_user.email_verified?
      redirect_to finish_signup_path(current_user)
    end
  end
  private

# ========================================================
# ============= GITHUB ===================================
# ========================================================
    def set_github_client
      if (user_signed_in? && current_user.identities.where(:provider => "github").present? )
        Koala.config.api_version = "v2.0"
        @@github_client = Github.new :client_id => ENV["github_key"], :client_secret => ENV["github_secret"]
      end
    end
    # def post_multiple_github_posts(user_client)
    #   user_commits = user_client.repos.commits.all('wvance', 'WesleyVance')
    #   # raise user_commits.inspect
    # end

# ========================================================
# ============= FACEBOOK =================================
# ========================================================
    def set_facebook_client
      if (user_signed_in? && current_user.identities.where(:provider => "facebook").present? )
        @@facebook_client = Koala::Facebook::API.new(current_user.identities.where(:provider => "facebook").first.token)

      end
    end
    def post_multiple_facebook_posts(user_client)
      user_timeline = user_client.get_connections("me", "feed")

      user_timeline.each do |post|
        content = Content.new
        content.user_id = current_user.id
        content.external_id = post['id']
        content.body = post['message']
        content.provider = "facebook"
        content.kind = "post"
        content.external_link = "http://facebook.com/" + content.external_id

        content.created_at = post['created_time'] || DateTime.now
        content.active = true

        content.log = post

        if (content.valid?)
          content.save!
        end

      end
    end
    def post_multiple_facebook_friends(user_client)
      user_friends = user_client.get_connections("me", "friends", api_version: 'v2.0')

      # raise user_friends.inspect
      user_friends.each do |friend|
        content = Content.new
        content.user_id = current_user.id

        # GRAB FRIEND NAME
        # content.body = friend.?

        content.provider = "facebook"
        content.kind = "friend"
        content.created_at = DateTime.now
        content.log = friend
      end
    end

# ========================================================
# ============= FITBIT ===================================
# ========================================================
    def set_fitbit_client
      if (user_signed_in? && current_user.identities.where(:provider => "fitbit").present? )
        @@fitbit_client = Fitgem::Client.new({
          consumer_key: ENV["fitbit_key"],
          consumer_secret: ENV["fitbit_secret"],
          token: current_user.identities.where(:provider => "fitbit").first.token,
          secret: current_user.identities.where(:provider => "fitbit").first.secret
        })
      end
    end
    def post_multiple_fitbit_activities(user_client)
      user_activity = user_client.recent_activities
      user_activity.each do |activity|
        # raise activity.inspect
        content = Content.new
        content.user_id = current_user.id
        content.external_id = activity["activityId"]
        content.title = activity["name"]
        content.body = activity["description"].to_s + " Calories:" + activity["calories"].to_s + " Duration:" + activity["duration"].to_s + " Distance:" + activity["distance"].to_s
        content.active = true
        content.external_link = "#"
        content.provider = "fitbit"
        content.kind = "activity"
        content.created_at = DateTime.now
        content.log = activity

        if (content.valid?)
          content.save!
        end
      end
    end

# ========================================================
# ============= FOURSQUARE ===============================
# ========================================================
    def set_foursquare_client
      if (user_signed_in? && current_user.identities.where(:provider => "foursquare").present? )
        @@foursquare_client = Foursquare2::Client.new(:oauth_token => current_user.identities.where(:provider => "foursquare").first.token, :api_version => '20140806')
      end
    end
    def user_checkins(user_client)
      raise user_client.user_checkins.items.inspect
    end
    def post_multiple_foursquare_checkins(user_client)
      user_checkins = user_client.user_checkins.items

      user_checkins.each do |checkin|
        content = Content.new
        content.user_id = current_user.id

        # raise checkin.inspect
        content.external_id = checkin.id
        content.body = checkin.text
        content.title = checkin.venue.name

        content.longitude = checkin.venue.location.lng
        content.latitude = checkin.venue.location.lat

        address = checkin.venue.location.formattedAddress[0].to_s + " " + checkin.venue.location.formattedAddress[1].to_s
        content.address = address

        content.active = true
        content.external_link = "#"
        # content.external_link = "http://foursquare.com/user/"+ user.id

        content.created_at = checkin.createdAt || DateTime.now
        content.provider = "foursquare"
        content.kind = "checkin"

        content.log = checkin
        if checkin.photos.items.first.present?
          content.image = checkin.photos.items.first
        end

        if (content.valid?)
          content.save!
        end
      end
    end

# ========================================================
# ============= TWITTER =================================
# ========================================================
    def set_twitter_client
      if (user_signed_in? && current_user.identities.where(:provider => "twitter").present? )
        @@twitter_client ||= Twitter::REST::Client.new do |config|
          config.consumer_key = ENV['twitter_key']
          config.consumer_secret = ENV['twitter_secret']
          config.access_token = current_user.identities.where(:provider => "twitter").first.token
          config.access_token_secret = current_user.identities.where(:provider => "twitter").first.secret
        end
      end
    end

    def user_timeline(user_client, qt)
      user_client.user_timeline(count: qt)
    end

    def post_multiple_tweets(user_client, count)
      # GET A USER'S TIMELINE GOING BACK AS FAR AS COUNT
      user_tweets = user_client.user_timeline(count: count)
      # raise user_tweets.inspect
      # LOOP THROUGH EACH TWEET IN USER TIMELINE AND CREATE 'NEW CONTENT'
      user_tweets.each do |tweet|
        content = Content.new
        content.user_id = current_user.id
        content.external_id = tweet.id
        content.body = tweet.text

        content.longitude = tweet.place.bounding_box.coordinates[0][0][0]
        content.latitude = tweet.place.bounding_box.coordinates[0][0][1]
        content.active = true
        content.external_link = tweet.url

        content.created_at = tweet.created_at || DateTime.now
        content.provider = "twitter"
        content.kind = "tweet"

        content.log = tweet
        if tweet.media.present?
          content.image = tweet.media[0].media_url
        end

        if (content.valid?)
          content.save!
        end
      end
    end

end
