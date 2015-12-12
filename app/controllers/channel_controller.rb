class ChannelController < ApplicationController
  def index
    if user_signed_in?
      @identities = current_user.identities.all

      @twitter = @identities.where(:provider => "twitter")
      @foursquare = @identities.where(:provider => "foursquare")
      @github = @identities.where(:provider => "github")
      @fitbit = @identities.where(:provider => "fitbit_oauth2")
      @facebook = @identities.where(:provider =>'facebook')
      @instagram = @identities.where(:provider => 'instagram')
    end
  end
end
