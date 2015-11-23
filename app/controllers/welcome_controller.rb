class WelcomeController < ApplicationController
  def index
    @all_users = User.all
    @all_providers = Identity.all
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
        post_multiple_foursquare_checkins(@@foursquare_client)
      end

      if current_user.identities.where(:provider => "fitbit").present?
        post_multiple_fitbit_activities(@@fitbit_client)
        post_multiple_fitbit_favorite_activities(@@fitbit_client)
      end

      if current_user.identities.where(:provider => "facebook").present?
        post_multiple_facebook_posts(@@facebook_client)
      end
      if current_user.identities.where(:provider =>"github").present?
        post_multiple_github_repos(@@github_client)
      end

      @userTweets = current_user.contents.where(:provider => "twitter")
      @userCheckins = current_user.contents.where(:provider=>"foursquare")
      @userActivities = current_user.contents.where(:provider=>"fitbit")
      @userGithub = current_user.contents.where(:provider=>"github")
      @userPosts = current_user.contents.where(:provider => "facebook")

    end
  end
end
