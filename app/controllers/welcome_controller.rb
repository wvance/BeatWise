class WelcomeController < ApplicationController
  def index
    # @facebook = current_user.identities.where(:provider => "facebook")
    if user_signed_in?
      @twitter = current_user.identities.where(:provider => "twitter")
      @foursquare = current_user.identities.where(:provider => "foursquare")
      @github = current_user.identities.where(:provider => "github")
      @fitbit = current_user.identities.where(:provider => "fitbit")
    end
    @identities = current_user.identities.all
    @all_identities = Identity.all
  end
end
