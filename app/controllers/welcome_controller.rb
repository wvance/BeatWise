class WelcomeController < ApplicationController
  def index
    # @facebook = current_user.identities.where(:provider => "facebook")
    if user_signed_in?
      @twitter = current_user.identities.where(:provider => "twitter")
      @foursquare = current_user.identities.where(:provider => "foursquare")
      @github = current_user.identities.where(:provider => "github")
      @fitbit = current_user.identities.where(:provider => "fitbit")

      if current_user.identities.where(:provider => "twitter").present?
        post_multiple_tweets(@@twitter_client, 5)
      end
      if current_user.identities.where(:provider => "foursquare").present?
        # user_checkins(@@foursquare_client)
        post_multiple_foursquare_checkins(@@foursquare_client)
      end
      @userTweets = current_user.contents
    end
  end
end
