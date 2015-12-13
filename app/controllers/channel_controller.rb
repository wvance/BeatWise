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
      @userTwitter = current_user.contents.order('created_at DESC').where(:provider => "twitter").page(params[:page]).per(10)
    end
    respond_to do |format|
      format.html
      format.csv { send_data @userTwitter.to_csv, filename: "Twitter_Timeline-#{Date.today}.csv" }
      format.json { render :json => @userTwitter }
    end
  end

  def fitbit
    @fitbit = @identities.where(:provider => "fitbit_oauth2")
    if @fitbit.present?
      @userFitbit = current_user.contents.order('created_at DESC').where(:provider => "fitbit").page(params[:page]).per(10)
    end
    respond_to do |format|
      format.html
      format.csv { send_data @userFitbit.to_csv, filename: "Fitbit_Timeline-#{Date.today}.csv" }
    end
  end

  def github
    @github = @identities.where(:provider => "github")
    if @github.present?
      @userGithub = current_user.contents.order('created_at DESC').where(:provider => "github").page(params[:page]).per(10)
    end
    respond_to do |format|
      format.html
      format.csv { send_data @userGithub.to_csv, filename: "Github_Timeline-#{Date.today}.csv" }
    end
  end

  def instagram
    @instagram = @identities.where(:provider => "instagram")
    if @instagram.present?
      @userInstagram = current_user.contents.order('created_at DESC').where(:provider => "instagram").page(params[:page]).per(10)
    end
    respond_to do |format|
      format.html
      format.csv { send_data @userInstagram.to_csv, filename: "Instagram_Timeline-#{Date.today}.csv" }
    end
  end

  def foursquare
    @foursquare = @identities.where(:provider => "foursquare")
    if @foursquare.present?
      @userFoursquare = current_user.contents.order('created_at DESC').where(:provider => "foursquare").page(params[:page]).per(10)
    end
    respond_to do |format|
      format.html
      format.csv { send_data @userFoursquare.to_csv, filename: "Foursquare_Timeline-#{Date.today}.csv" }
    end
  end

  def facebook
    @facebook = @identities.where(:provider => "facebook")
    if @facebook.present?
      @userFacebook = current_user.contents.order('created_at DESC').where(:provider => "facebook").page(params[:page]).per(10)
    end
    respond_to do |format|
      format.html
      format.csv { send_data @userFacebook.to_csv, filename: "Facebook_Timeline-#{Date.today}.csv" }
    end
  end

  private
    def set_identities
      @identities = current_user.identities.all
    end
end
