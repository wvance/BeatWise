class WelcomeController < ApplicationController
  def index
    @all_users = User.all
    # @facebook = current_user.identities.where(:provider => "facebook")
    if user_signed_in?
      @twitter = current_user.identities.where(:provider => "twitter")
      @foursquare = current_user.identities.where(:provider => "foursquare")
      @github = current_user.identities.where(:provider => "github")
      @fitbit = current_user.identities.where(:provider => "fitbit")
      @facebook = current_user.identities.where(:provider =>'facebook')

      if current_user.identities.where(:provider => "twitter").present?
        post_multiple_tweets(@@twitter_client, 5)
      end
      if current_user.identities.where(:provider => "foursquare").present?
        # user_checkins(@@foursquare_client)
        post_multiple_foursquare_checkins(@@foursquare_client)
      end

      if current_user.identities.where(:provider => "fitbit").present?
        post_multiple_fitbit_activities(@@fitbit_client)
      end

      if current_user.identities.where(:provider => "facebook").present?
        # post_multiple_facebook_posts(@@facebook_client)
      end
      if current_user.identities.where(:provider =>"github").present?
        # post_multiple_github_posts(@@github_client)
      end

      @userTweets = current_user.contents.where(:provider => "twitter")
      @userCheckins = current_user.contents.where(:provider=>"foursquare")
      @userActivities = current_user.contents.where(:provider=>"fitbit")
      @userCommits = current_user.contents.where(:provider=>"github")

    end
  end
end
