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
      @all_fitbitContent = current_user.contents.where(:provider => "fitbit")

      # @allUserFitbit = current_user.contents.where(:provider => "fitbit")
      @userContent = @all_fitbitContent.page(params[:page]).per(10)

      # GETS UNIQUE NUMBER OF DAYS IN DATABASE
      @all_fitbitContentDates = @all_fitbitContent.uniq.pluck('DATE(created_at)').sort.reverse

      # raise @all_fitbitContentDates.inspect
      if params[:first_day].present?
        first_day = params[:first_day].to_i
        last_day = params[:last_day].to_i
        # raise last_day.inspect
      else
        first_day = 2
        last_day = first_day + 1
      end

      @fitbitContent= @all_fitbitContent.where('created_at < ? AND created_at > ?', first_day.days.ago, last_day.days.ago)
    end
    respond_to do |format|
      format.html
      format.csv { send_data @allUserFitbit.to_csv, filename: "Fitbit_Timeline-#{Date.today}.csv" }
    end
  end

  def fitbitChart
    @fitbit = @identities.where(:provider => "fitbit_oauth2")
    if @fitbit.present?
      @all_fitbitContent = current_user.contents.where(:provider => "fitbit")

      # @allUserFitbit = current_user.contents.where(:provider => "fitbit")
      @userContent = @all_fitbitContent.page(params[:page]).per(10)

      # GETS UNIQUE NUMBER OF DAYS IN DATABASE
      @all_fitbitContentDates = @all_fitbitContent.uniq.pluck('DATE(created_at)').sort

      # raise @all_fitbitContentDates.inspect
      if params[:first_day].present?
        first_day = params[:first_day].to_i
        last_day = params[:last_day].to_i
        # raise last_day.inspect
      else
        first_day = 2
        last_day = first_day + 1
      end

      @fitbitContent= @all_fitbitContent.where('created_at < ? AND created_at > ?', first_day.days.ago, last_day.days.ago)
    end

    respond_to do |format|
      format.json
    end
  end

  private
    def set_identities
      @identities = current_user.identities.all
    end
end
