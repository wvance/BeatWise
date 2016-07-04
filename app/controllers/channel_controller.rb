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

      if @all_fitbitContentDates.present?
        @numberOfDays = (@all_fitbitContentDates[0] - @all_fitbitContentDates[@all_fitbitContentDates.count-1] +1).to_i

        if @numberOfDays > 12
          @numberOfDays = 12
        end
      end

      @fitbitContent= @all_fitbitContent
    end
    respond_to do |format|
      format.html
      format.csv { send_data @all_fitbitContent.to_csv, filename: "Fitbit_Timeline-#{Date.today}.csv" }
      format.json {@all_fitbitContent}
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
      if params[:days_ago].present?
        days_ago = params[:days_ago].to_i
        # raise last_day.inspect
      else
        days_ago = 0
      end
      # raise first_day.days.inspect
      @selected_date = Date.today - days_ago.days
      # Comment.where(:created_at => @selected_date.beginning_of_day..@selected_date.end_of_day)
      # raise @selected_date.inspect
      @fitbitContent= @all_fitbitContent.where(:created_at => @selected_date.beginning_of_day..@selected_date.end_of_day)
    end
  end

  def showDay
    @date = params[:date].to_date
    @days_ago = Date.today - @date
    @content = current_user.contents.where("created_at::date = ?", @date)

    @hoursAsleep = (@content.where(:tag => "sleeping").count.to_f / 60).round(2)
    @hoursInClass = (@content.where(:tag => "class").count.to_f / 60).round(2)
    @hoursDriving = (@content.where(:tag => "driving").count.to_f / 60).round(2)
    @hoursPhysical = (@content.where(:tag => "physical").count.to_f / 60).round(2)
    @hoursRelaxing = (@content.where(:tag => "relaxing").count.to_f / 60).round(2)
    # raise @hoursAsleep.to_s.inspect
    @userContent = @content.page(params[:page]).per(10)
  end

  private
    def set_identities
      @identities = current_user.identities.all
    end
end
