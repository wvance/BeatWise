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
      @userTwitter = current_user.contents.order('created_at DESC').where(:provider => "twitter")
    end
  end

  def fitbit
    @fitbit = @identities.where(:provider => "fitbit_oauth2")
    if @fitbit.present?
      @userFitbit = current_user.contents.order('created_at DESC').where(:provider => "fitbit")
    end
  end

  def github
    @github = @identities.where(:provider => "github")
    if @github.present?
      @userGithub = current_user.contents.order('created_at DESC').where(:provider => "github")
    end
  end

  def instagram
    @instagram = @identities.where(:provider => "instagram")
    if @instagram.present?
      @userInstagram = current_user.contents.order('created_at DESC').where(:provider => "instagram")
    end
  end

  def foursquare
    @foursquare = @identities.where(:provider => "foursquare")
    if @foursquare.present?
      @userFoursquare = current_user.contents.order('created_at DESC').where(:provider => "foursquare")
    end
  end

  def facebook
    @facebook = @identities.where(:provider => "facebook")
    if @facebook.present?
      @userFacebook = current_user.contents.order('created_at DESC').where(:provider => "facebook")
    end
  end

  private
    def set_identities
      @identities = current_user.identities.all
    end
end
