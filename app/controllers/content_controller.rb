class ContentController < ApplicationController
  # THESE ARE USED TO SET UP THE CLIENTS, ONLY IF A PROVIDER IS PRESENT!
  before_action :set_facebook_client
  before_action :set_fitbit_client
  before_action :set_foursquare_client
  before_action :set_github_client
  before_action :set_twitter_client

  # before_action :new_content #, only: []

# ========================================================
# ============= TWITTER ==================================
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

  def get_twitter_tweets
    user_tweets = @@twitter_client.user_timeline(count: 100)

    user_tweets.each do |tweet|
      @content = Content.new
      @content.post_tweet(tweet, current_user.id)
    end

    respond_to do |format|
      format.html { redirect_to root_url, notice:"Updated Twitter Tweets" }
      format.json { head :no_content }
    end
  end

# ========================================================
# ============= GITHUB ===================================
# ========================================================
  def set_github_client
    if (user_signed_in? && current_user.identities.where(:provider => "github").present? )
      @@github_client = Github.new :oauth_token => current_user.identities.where(:provider => "github").first.token
    end
  end

  def get_github_repos
    user_repos = @@github_client.repos.list

    user_repos.each do |repo|
      @content = Content.new
      @content.post_github_repo(repo, current_user.id)
    end

    respond_to do |format|
      format.html { redirect_to root_url, notice:"Updated All Github" }
      format.json { head :no_content }
    end
  end

# ========================================================
# ============= FACEBOOK =================================
# ========================================================
  def set_facebook_client
    if (user_signed_in? && current_user.identities.where(:provider => "facebook").present? )
      Koala.config.api_version = "v2.0"
      @@facebook_client = Koala::Facebook::API.new(current_user.identities.where(:provider => "facebook").first.token)

    end
  end

  def get_facebook_all
    user_timeline = @@facebook_client.get_connections("me", "feed", {limit: 100})
    user_timeline.each do |post|
      @content = Content.new
      @content.post_facebook_post(post, current_user.id)
    end

    user_likes = @@facebook_client.get_connections("me", "likes")
    user_likes.each do |like|
      @content = Content.new
      @content.post_facebook_user_like(like, current_user.id)
    end

    user_events = @@facebook_client.get_connections("me", "events")
    user_events.each do |event|
      @content = Content.new
      @content.post_facebook_user_event(event, current_user.id)
    end

    user_photos = @@facebook_client.get_connections("me", "photos", {limit: 100})
    user_photos.each do |photo|
      @content = Content.new
      @content.post_facebook_user_photo(photo, current_user.id)
    end

    user_family = @@facebook_client.get_connections("me", "family")
    user_family.each do |member|
      @content = Content.new
      @content.post_facebook_user_family(member, current_user.id)
    end


    respond_to do |format|
      format.html { redirect_to root_url, notice:"Updated All Facebook" }
      format.json { head :no_content }
    end
  end

  def get_facebook_posts
    user_timeline = @@facebook_client.get_connections("me", "feed", {limit: 100})
    user_timeline.each do |post|
      @content = Content.new
      @content.post_facebook_post(post, current_user.id)
    end

    respond_to do |format|
      format.html { redirect_to root_url, notice:"Updated Facebook Posts"}
      format.json { head :no_content}
    end
  end

  def get_facebook_likes
    user_likes = @@facebook_client.get_connections("me", "likes")
    user_likes.each do |like|
      @content = Content.new
      @content.post_facebook_user_like(like, current_user.id)
    end

    respond_to do |format|
      format.html { redirect_to root_url, notice:"Updated Facebook Likes"}
      format.json { head :no_content}
    end
  end

  def get_facebook_events
    user_events = @@facebook_client.get_connections("me", "events")
    user_events.each do |event|
      @content = Content.new
      @content.post_facebook_user_event(event, current_user.id)
    end

    respond_to do |format|
      format.html { redirect_to root_url, notice:"Updated Facebook Events" }
      format.json { head :no_content}
    end
  end

  def get_facebook_photos
    user_photos = @@facebook_client.get_connections("me", "photos", {limit: 100})
    user_photos.each do |photo|
      @content = Content.new
      @content.post_facebook_user_photo(photo, current_user.id)
    end

    respond_to do |format|
      format.html { redirect_to root_url, notice:"Updated Facebook Photos" }
      format.json { head :no_content}
    end
  end

  def get_facebook_family
    user_family = @@facebook_client.get_connections("me", "family")
    user_family.each do |member|
      @content = Content.new
      @content.post_facebook_user_family(member, current_user.id)
    end

    respond_to do |format|
      format.html { redirect_to root_url, notice:"Updated Facebook Family"}
      format.json { head :no_content}
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

  def get_foursquare_all
    user_checkins = @@foursquare_client.user_checkins.items
    user_checkins.each do |checkin|
      @content = Content.new
      @content.post_foursquare_checkin(checkin, current_user.id)
    end

    user_friends = @@foursquare_client.user_friends('self').items
    user_friends.each do |friend|
      @content = Content.new
      @content.post_foursquare_user_friend(friend, current_user.id)
    end

    respond_to do |format|
      format.html { redirect_to root_url, notice:"Updated All Foursquare" }
      format.json { head :no_content }
    end
  end

  def get_foursquare_checkins
    user_checkins = @@foursquare_client.user_checkins.items

    user_checkins.each do |checkin|
      @content = Content.new
      @content.post_foursquare_checkin(checkin, current_user.id)
    end

    respond_to do |format|
      format.html { redirect_to root_url, notice:"Updated Foursquare Checkins"}
      format.json { head :no_content}
    end
  end
  def get_foursquare_friends
    user_friends = @@foursquare_client.user_friends('self').items

    user_friends.each do |friend|
      @content = Content.new
      @content.post_foursquare_user_friend(friend, current_user.id)
    end

    respond_to do |format|
      format.html { redirect_to root_url, notice:"Updated Foursquare Friends" }
      format.json { head :no_content}
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


  def get_fitbit_recent_activitity
    user_activity = @@fitbit_client.recent_activities
    user_activity.each do |activity|
      @content = Content.new
      @content.post_fitbit_recent_activity(activity, current_user.id)
    end

    respond_to do |format|
      format.html { redirect_to root_url, notice:"Updated Fitbit Recent Activity"}
      format.json { head :no_content}
    end
  end

  def get_fitbit_favorite_activities
    favorite_activities = @@fitbit_client.favorite_activities

    favorite_activities.each do |activity|
      @content = Content.new
      @content.post_fitbit_favorite_activity(activity, current_user.id)
    end

    respond_to do |format|
      format.html { redirect_to root_url, notice:"Updated Fitbit Favorite Activities" }
      format.json { head :no_content}
    end
  end

  def get_fitbit_heart_rates
    heart_rates = @@fitbit_client.heart_rate_on_date('today', "1m")
    raise heart_rates.inspect
  end
end
