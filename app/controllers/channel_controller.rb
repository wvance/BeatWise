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
      @allUserTwitter = current_user.contents.where(:provider => "twitter")
      @userContent = @allUserTwitter.order('created_at DESC').where(:provider => "twitter").page(params[:page]).per(10)
    end
    respond_to do |format|
      format.html
      format.csv { send_data @userContent.to_csv, filename: "Twitter_Timeline-#{Date.today}.csv" }
      format.json { render :json => @userContent }
    end
  end

  def fitbit
    @fitbit = @identities.where(:provider => "fitbit_oauth2")
    if @fitbit.present?
      @allUserFitbit = current_user.contents.where(:provider => "fitbit")
      @userContent = @allUserFitbit.order('created_at DESC').page(params[:page]).per(10)

      sleepHash = {"" => 0}

      @allUserFitbit.each do |day|
        unless day.body.to_i == 0
          date = day.created_at.strftime("%b %e, %Y")
          sleep = day.body.to_i
          sleepHash[date] = (sleep / 60.0).round(2)
        end
      end
      @fitbitSleepChart = sleepHash

    end
    respond_to do |format|
      format.html
      format.csv { send_data @userContent.to_csv, filename: "Fitbit_Timeline-#{Date.today}.csv" }
    end
  end

  def github
    @github = @identities.where(:provider => "github")
    if @github.present?
      @allUserGithub = current_user.contents.where(:provider => "github")
      @userContent = @allUserGithub.order('created_at DESC').page(params[:page]).per(10)
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
      @allUserFoursquare = current_user.contents.where(:provider => "foursquare")
      @userContent = @allUserFoursquare.order('created_at DESC').page(params[:page]).per(10)
    end
    respond_to do |format|
      format.html
      format.csv { send_data @userFoursquare.to_csv, filename: "Foursquare_Timeline-#{Date.today}.csv" }
    end
  end

  def facebook
    @facebook = @identities.where(:provider => "facebook")
    if @facebook.present?
      @allUserFacebook = current_user.contents.where(:provider => "facebook")
      @userContent = @allUserFacebook.order('created_at DESC').page(params[:page]).per(10)
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
