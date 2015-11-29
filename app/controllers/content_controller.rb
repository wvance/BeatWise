class ContentController < ApplicationController
  # THESE ARE USED TO SET UP THE CLIENTS, ONLY IF A PROVIDER IS PRESENT!
  before_action :set_twitter_client
  before_action :set_foursquare_client
  before_action :set_fitbit_client
  before_action :set_facebook_client
  before_action :set_github_client

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

  # def get_twitter_all
  #   @content = Content.new
  #   @content.post_multiple_tweets(@@twitter_client, current_user.id, 100)

  #   respond_to do |format|
  #     format.html { redirect_to root_url }
  #     format.json { head :no_content }
  #   end
  # end

  def get_twitter_tweets
    @content = Content.new
    @content.post_multiple_tweets(@@twitter_client, current_user.id, 100)

    respond_to do |format|
      format.html { redirect_to root_url }
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

  def get_github_repos_commits
    @content = Content.new
    @content.post_multiple_github_repos(@@github_client, current_user.id)

    respond_to do |format|
      format.html { redirect_to root_url }
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
    @content = Content.new
    @content.post_multiple_facebook_posts(@@facebook_client, current_user.id)
    @content.post_multiple_facebook_user_likes(@@facebook_client, current_user.id)
    @content.post_multiple_facebook_user_events(@@facebook_client, current_user.id)
    @content.post_multiple_facebook_user_photos(@@facebook_client, current_user.id)
    @content.post_multiple_facebook_user_family(@@facebook_client, current_user.id)

    respond_to do |format|
      format.html { redirect_to root_url }
      format.json { head :no_content }
    end
  end

  def get_facebook_posts
    @content = Content.new
    @content.post_multiple_facebook_posts(@@facebook_client, current_user.id)

    respond_to do |format|
      format.html { redirect_to root_url }
      format.json { head :no_content }
    end
  end

  def get_facebook_likes
    @content = Content.new
    @content.post_multiple_facebook_user_likes(@@facebook_client, current_user.id)

    respond_to do |format|
      format.html { redirect_to root_url }
      format.json { head :no_content }
    end
  end

  def get_facebook_events
    @content = Content.new
    @content.post_multiple_facebook_user_events(@@facebook_client, current_user.id)

    respond_to do |format|
      format.html { redirect_to root_url }
      format.json { head :no_content }
    end
  end

  def get_facebook_photos
    @content = Content.new
    @content.post_multiple_facebook_user_photos(@@facebook_client, current_user.id)

    respond_to do |format|
      format.html { redirect_to root_url }
      format.json { head :no_content }
    end
  end

  def get_facebook_family
    @content = Content.new
    @content.post_multiple_facebook_user_family(@@facebook_client, current_user.id)

    respond_to do |format|
      format.html { redirect_to root_url }
      format.json { head :no_content }
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
    @content = Content.new
    @content.post_multiple_foursquare_checkins(@@foursquare_client, current_user.id)
    @content.post_multiple_foursquare_user_friends(@@foursquare_client, current_user.id)

    respond_to do |format|
      format.html { redirect_to root_url }
      format.json { head :no_content }
    end
  end

  def get_foursquare_checkins
    @content = Content.new
    @content.post_multiple_foursquare_checkins(@@foursquare_client, current_user.id)

    respond_to do |format|
      format.html { redirect_to root_url }
      format.json { head :no_content }
    end
  end
  def get_foursquare_friends
    @content = Content.new
    @content.post_multiple_foursquare_user_friends(@@foursquare_client, current_user.id)

    respond_to do |format|
      format.html { redirect_to root_url }
      format.json { head :no_content }
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

  def get_fitbit_favorite_activities
    @content = Content.new
    @content.post_multiple_fitbit_favorite_activities(@@fitbit_client, current_user.id)

    respond_to do |format|
      format.html { redirect_to root_url }
      format.json { head :no_content }
    end
  end

  def get_fitbit_recent_activities
    @content = Content.new
    @content.post_multiple_fitbit_activities(@@fitbit_client, current_user.id)

    respond_to do |format|
      format.html { redirect_to root_url }
      format.json { head :no_content }
    end
  end
end
