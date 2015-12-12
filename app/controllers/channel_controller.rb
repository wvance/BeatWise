class ChannelController < ApplicationController
  before_action :set_identities
  def index
    if user_signed_in?
      @twitter = @identities.where(:provider => "twitter")
      @foursquare = @identities.where(:provider => "foursquare")
      @github = @identities.where(:provider => "github")
      @fitbit = @identities.where(:provider => "fitbit_oauth2")
      @facebook = @identities.where(:provider =>'facebook')
      @instagram = @identities.where(:provider => 'instagram')
    end
  end
  def twitter
    @twitter = @identities.where(:provider => "twitter")
    if @twitter.present?
      @userTweets = current_user.contents.order('created_at DESC').where(:provider => "twitter")
    end
  end

  private
    def set_identities
      @identities = current_user.identities.all
    end
end
