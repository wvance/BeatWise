class ChannelController < ApplicationController
  before_action :authenticate_user!
  before_action :set_identities
  def index
    @twitter = @identities.where(:provider => "twitter")
    @fitbit = @identities.where(:provider => "fitbit_oauth2")
  end

  def twitter
    @twitter = @identities.where(:provider => "twitter")
    if @twitter.present?
      @allUserTwitter = current_user.contents.where(:provider => "twitter")
      @userContent = @allUserTwitter.order('created_at DESC').where(:provider => "twitter").page(params[:page]).per(10)
    end
    respond_to do |format|
      format.html
      format.csv { send_data @allUserTwitter.to_csv, filename: "Twitter_Timeline-#{Date.today}.csv" }
      format.json { render :json => @userContent }
    end
  end

  def fitbit
    @fitbit = @identities.where(:provider => "fitbit_oauth2")
    if @fitbit.present?
      # @allUserFitbit = current_user.contents.where(:provider => "fitbit")
      @userContent = current_user.contents.where(:provider => "fitbit").order('created_at DESC').page(params[:page]).per(10)


      # raise @userContent.inspect
      # sleepHash = {"" => 0}

      # @allUserFitbit.each do |day|
      #   unless day.body.to_i == 0
      #     date = day.created_at.strftime("%b %e, %Y")
      #     sleep = day.body.to_i
      #     sleepHash[date] = (sleep / 60.0).round(2)
      #   end
      # end
      # @fitbitSleepChart = sleepHash

    end
    respond_to do |format|
      format.html
      format.csv { send_data @allUserFitbit.to_csv, filename: "Fitbit_Timeline-#{Date.today}.csv" }
    end
  end

  private
    def set_identities
      @identities = current_user.identities.all
    end
end
