class ContentController < ApplicationController
  before_action :authenticate_user!
  before_action :set_content, only: [:show, :edit, :update, :destroy]
  before_action :set_author, only: [:show]
  # before_action :verify_is_admin, only: [:index]
  before_action :verify_is_owner, only: [:show, :index]

  before_action :set_reddit_client

def set_reddit_client
  # if (user_signed_in? && current_user.identities.where(:provider => "github").present? )
  #   @@github_client = Github.new :oauth_token => current_user.identities.where(:provider => "github").first.token
  # end
end

def index
  @userContent = current_user.contents.all
end

def show

  # THIS IS FOR THE DISPLAY MAP
  @geojson = Array.new

  # PUT CONTENTS ON MAP
  puts @content.kind
  if (@content.provider == "twitter")
    marker_color = '#4099FF'
  elsif (@content.provider == "foursquare")
    marker_color = '#FFCC00'
  elsif (@content.provider == "facebook")
    marker_color = '#FFFFFF'
  elsif (@content.provider == "fitbit")
    marker_color = '#f15038'
  elsif (@content.provider == "github")
    marker_color = '#F1AC38'
  else
    marker_color = "#387C81"
  end

  unless (@content.longitude.nil? || @content.latitude.nil?) || (@content.longitude == '0' || @content.latitude == '0')
    @geojson << {
      type: 'Feature',
      geometry: {
        type: 'Point',
        coordinates: [
          @content.longitude,
          @content.latitude
        ]
      },
      properties: {
        title:
          if (@content.title.present?)
            @content.title.capitalize
          elsif (@content.provider.present? && @content.kind.present? && !@content.body.present? )
            @content.provider.capitalize + " " + @content.kind.capitalize
          elsif (@content.provider.present?)
            @content.provider.capitalize
          else
            " "
          end,
        body:
          if (@content.body.present?)
            @content.body.capitalize
          elsif (@content.kind.present?)
            @content.kind.capitalize
          else
            " "
          end,
        external_link:
          if (@content.external_link.present?)
            @content.external_link
          else
            "http://blackboxapp.io/content/"+ @content.id
          end,
        address:
          if (@content.city.present? && @content.state.present?)
            @content.city + ", " + @content.state
          elsif @content.location.present?
            @content.location
          end,
        :'marker-color' => marker_color,
        :'marker-size' => 'small'
      }
    }
  end
  puts "START MAP OBJECT: "
  puts @geojson
  puts "END MAP OBJECT: "

  respond_to do |format|
    format.html
    format.json { render json: @geojson }  # respond with the created JSON object
    # format.js
  end
end

# GET CONTENT: ACTIONS BELOW
# ========================================================
# ============= INSTAGRAM ================================
# ========================================================
  def set_instagram_client
    if (user_signed_in? && current_user.identities.where(:provider => "instagram").present? )
      # @@instagram_client = Instagram.client(:access_token => current_user.identities.where(:provider => "instagram").first.token)
    end
  end

  def get_instagram_photos
    user_photos = @@instagram_client
    raise user_photos.inspect
  end

# ========================================================
# ============= TWITTER ==================================
# ========================================================
  def get_twitter_tweets
    TwitterDataJob.perform_later current_user.id
    respond_to do |format|
      format.html { redirect_to request.referrer, notice:"Updating All Twitter" }
      format.json { head :no_content }
    end
  end

# ========================================================
# ============= REDDIT ===================================
# ========================================================
  def reddit_all_data

  end

# ========================================================
# ============= GITHUB ===================================
# ========================================================
  # def set_github_client
  #   if (user_signed_in? && current_user.identities.where(:provider => "github").present? )
  #     @@github_client = Github.new :oauth_token => current_user.identities.where(:provider => "github").first.token
  #   end
  # end

  def get_github_repos
    GithubDataJob.perform_later current_user.id

    respond_to do |format|
      format.html { redirect_to request.referrer, notice:"Updating All Github" }
      format.json { head :no_content }
    end
  end

# ========================================================
# ============= FACEBOOK =================================
# ========================================================
  def set_facebook_client
    if (user_signed_in? && current_user.identities.where(:provider => "facebook").present? )
      Koala.config.api_version = "v2.0"
      @@facebook_client = Koala::Facebook::API.new(current_user.identities.where(:provider => "facebook").first.token)

    end
  end

  def get_facebook_all
    # FacebookDataJob.perform_later current_user.id

      Koala.config.api_version = "v2.0"
      @@facebook_client = Koala::Facebook::API.new(current_user.identities.where(:provider => "facebook").first.token)


      user_photos = @@facebook_client.get_connection('me', 'photos',
        {limit: 100,
          fields: ['message', 'id', 'from', 'type', 'status_type', 'shares',
            'picture', 'link', 'created_time', 'place', 'likes', 'comments'
        ]})
      user_photos.each do |photo|
        @content = Content.new
        @content.post_facebook_user_photo(photo, current_user.id)
      end

      # user_timeline.each do |post|
      #   @content = Content.new
      #   @content.post_facebook_post(post, current_user.id)
      # end

    respond_to do |format|
      format.html { redirect_to request.referrer, notice:"Updating All Facebook" }
      format.json { head :no_content }
    end
  end

  def get_facebook_family
    user_family = @@facebook_client.get_connections("me", "family")
    user_family.each do |member|
      @content = Content.new
      @content.post_facebook_user_family(member, current_user.id)
    end

    respond_to do |format|
      format.html { redirect_to request.referrer, notice:"Updated Facebook Family"}
      format.json { head :no_content}
    end
  end

# ========================================================
# ============= FOURSQUARE ===============================
# ========================================================
  def set_foursquare_client
    if (user_signed_in? && current_user.identities.where(:provider => "foursquare").present? )
      @@foursquare_client = Foursquare2::Client.new(:oauth_token => current_user.identities.where(:provider => "foursquare").first.token, :api_version => '20140806')
    end
  end

  def get_foursquare_all
    FoursquareDataJob.perform_later current_user.id

    respond_to do |format|
      format.html { redirect_to request.referrer, notice:"Updating All Foursquare" }
      format.json { head :no_content }
    end
  end

  def get_foursquare_friends
    user_friends = @@foursquare_client.user_friends('self').items

    user_friends.each do |friend|
      @content = Content.new
      @content.post_foursquare_user_friend(friend, current_user.id)
    end

    respond_to do |format|
      format.html { redirect_to request.referrer, notice:"Updated Foursquare Friends" }
      format.json { head :no_content}
    end
  end

# ========================================================
# ============= FITBIT ===================================
# ========================================================
  def set_fitbit_client
    if (user_signed_in? && current_user.identities.where(:provider => "fitbit_oauth2").present? )
      @@fitbit_client = Fitbit::Client.new(
        ENV["fitbit_client_id"],
        ENV["fitbit_secret"],
        current_user.identities.where(:provider => "fitbit_oauth2").first.token
      )
    end
  end
  def fitbit_all_data
    FitbitDataJob.perform_later current_user.id

    respond_to do |format|
      format.html { redirect_to request.referrer, notice:"Updating all Fitbit Data"}
      format.json { head :no_content}
    end
  end

  def get_fitbit_recent_activitity
    user_activity = @@fitbit_client.recent_activities
    user_activity.each do |activity|
      @content = Content.new
      @content.post_fitbit_recent_activity(activity, current_user.id)
    end

    respond_to do |format|
      format.html { redirect_to request.referrer, notice:"Updated Fitbit Recent Activity"}
      format.json { head :no_content}
    end
  end

  def get_fitbit_favorite_activities
    favorite_activities = @@fitbit_client.favorite_activities

    favorite_activities.each do |activity|
      @content = Content.new
      @content.post_fitbit_favorite_activity(activity, current_user.id)
    end

    respond_to do |format|
      format.html { redirect_to request.referrer, notice:"Updated Fitbit Favorite Activities" }
      format.json { head :no_content}
    end
  end

  def get_fitbit_daily_min_sleep
    today = DateTime.current.strftime("%F")
    yesterday = DateTime.yesterday.strftime("%F")
    lastmonth = 1.month.ago.strftime("%F")

    sleep = @@fitbit_client.sleep_time_series(resource_path: 'sleep/minutesAsleep', date: today, period: '1y')
    sleep = sleep['sleep-minutesAsleep']

    sleep.each do |day|
      if (day['value'] != "0")
        date = day['dateTime']
        sleep_log = @@fitbit_client.sleep_logs(date: date)
        sleep_log = sleep_log['sleep'].first

        @content = Content.new
        @content.post_fitbit_daily_sleep_log(sleep_log, current_user.id)
      end
    end

    respond_to do |format|
      format.html { redirect_to request.referrer, notice:"Updated Fitbit Heart Rates" }
      format.json { head :no_content}
    end
  end

  def get_fitbit_daily_heart_rate
    today = DateTime.current.strftime("%F")
    yesterday = DateTime.yesterday.strftime("%F")
    lastmonth = 1.month.ago.strftime("%F")

    heart_rates = @@fitbit_client.heart_rate_time_series(date: today, period: '1d')
    heart_rates = heart_rates['activities-heart']

    heart_rates.each do |day|
      @content = Content.new
      @content.post_fitbit_daily_heart_rate(day, current_user.id)
    end

    respond_to do |format|
      format.html { redirect_to request.referrer, notice:"Updated Fitbit Heart Rates" }
      format.json { head :no_content}
    end
  end

  private
    # def verify_is_admin
    #   (current_user.nil?) ? redirect_to(root_path) : (redirect_to(root_path) unless current_user.admin?)
    # end
    def verify_is_owner
      if (current_user == User.where(:id => @content.user_id).first)
        return
      else
        redirect_to(root_path)
      end
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_content
      @content = Content.find(params[:id])
    end

    def set_author
      @contentAuthor = User.where(:id => @content.user_id).first
    end
    # Never trust parameters from the scary internet, only allow the white list through.
    def content_params
      params.require(:content).permit(:title, :author, :body, :image, :external_id, :external_link, :kind, :rating, :location, :address, :city, :state, :country, :postal, :ip, :latitude, :longitude, :is_active, :has_comments, :created, :updated)
    end

end
