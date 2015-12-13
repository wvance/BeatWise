class WelcomeController < ApplicationController
  def index
    @all_users = User.all
    @all_providers = Identity.all
    if user_signed_in?
      @twitter = current_user.identities.where(:provider => "twitter")
      @foursquare = current_user.identities.where(:provider => "foursquare")
      @github = current_user.identities.where(:provider => "github")
      @fitbit = current_user.identities.where(:provider => "fitbit_oauth2")
      @facebook = current_user.identities.where(:provider =>'facebook')
      @instagram = current_user.identities.where(:provider => 'instagram')

      @timeline = current_user.contents.order('created_at DESC').all

      @userTweets = current_user.contents.order('created_at DESC').where(:provider => "twitter")
      @userCheckins = current_user.contents.order('created_at DESC').where(:provider=>"foursquare")
      @userActivities = current_user.contents.order('created_at DESC').where(:provider=>"fitbit")
      @userGithub = current_user.contents.order('created_at DESC').where(:provider=>"fitbit_oauth2")
      @userPosts = current_user.contents.order('created_at DESC').where(:provider => "facebook")

    end

    respond_to do |format|
      format.html
      format.csv { send_data @timeline.to_csv, filename: "Content_Timeline-#{Date.today}.csv" }
    end
  end
end
