class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # THESE ARE USED TO SET UP THE CLIENTS, ONLY IF A PROVIDER IS PRESENT!
  before_action :set_twitter_client
  before_action :set_foursquare_client
  before_action :set_fitbit_client
  before_action :set_facebook_client
  before_action :set_github_client

  def ensure_signup_complete
    # Ensure we don't go into an infinite loop
    return if action_name == 'finish_signup'

    # Redirect to the 'finish_signup' page if the user
    # email hasn't been verified yet
    if current_user && !current_user.email_verified?
      redirect_to finish_signup_path(current_user)
    end
  end
  private

# ========================================================
# ============= GITHUB ===================================
# ========================================================
    def set_github_client
      if (user_signed_in? && current_user.identities.where(:provider => "github").present? )
        @@github_client = Github.new :oauth_token => current_user.identities.where(:provider => "github").first.token
      end
    end
    def post_multiple_github_repos(user_client)
      user_repos = user_client.repos.list
      user_repos.each do |repo|
        content = Content.new
        content.user_id = current_user.id
        content.external_id = repo.id

        content.title = repo.full_name
        content.body = repo.description
        content.external_link = repo.html_url

        content.provider = "github"
        content.kind = "repo"

        content.created_at = repo.created_at || DateTime.now
        content.active = true
        content.log = repo.to_hash

        # GET REPO COMMITS FROM THE CURRENT REPO: CALL FUNCTION TO SAVE THOSE
        # HOW TO CHECK IF THIS IS EMPTY???
        # raise user_client.repos.commits.list(repo.owner.login, repo.name).inspect
        if user_client.repos.commits.list(repo.owner.login, repo.name)
          repo_commits = user_client.repos.commits.list(repo.owner.login, repo.name)
          post_multiple_github_commits(repo_commits, content.id)
        end

        if (content.valid?)
          content.save!
        end
      end
    end
    def post_multiple_github_commits(repo_commits, parent_repo_id)
      repo_commits.each do |commit|
        puts "COMMIT ID: " + commit.sha
        commit_content = Content.new
        commit_content.user_id = current_user.id
        commit_content.external_id = commit.sha

        commit_content.title = commit.commit.author.name
        commit_content.body = commit.commit.message
        commit_content.external_link = commit.html_url

        commit_content.provider = "github"
        commit_content.kind = "commit"
        commit_content.active = true

        commit_content.created_at = commit.commit.author.date || DateTime.now
        commit_content.parent = parent_repo_id
        commit_content.log = commit.to_hash

        if (commit_content.valid?)
          commit_content.save!
        end
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
    def post_multiple_facebook_posts(user_client)
      user_timeline = user_client.get_connections("me", "feed", {limit: 100})
      user_timeline.each do |post|
        content = Content.new
        content.user_id = current_user.id
        content.external_id = post['id']
        content.body = post['message']
        content.provider = "facebook"
        content.kind = "post"
        content.external_link = "http://facebook.com/" + content.external_id

        content.created_at = post['created_time'] || DateTime.now
        content.active = true

        content.log = post.to_hash

        if (content.valid?)
          content.save!
        end

      end
    end
    def post_multiple_facebook_user_likes(user_client)
      user_likes = user_client.get_connections("me", "likes")

      user_likes.each do |like|
        content = Content.new
        content.user_id = current_user.id
        content.external_id = like['id']
        content.body = like['name']

        content.external_link = "http://facebook.com/" + content.external_id
        content.provider = "facebook"
        content.kind = "like"

        content.created_at = like['created_time'] || DateTime.now
        content.active = true

        content.log = like.to_hash

        if (content.valid?)
          content.save!
        end
      end
    end
    def post_multiple_facebook_user_events(user_client)
      user_events = user_client.get_connections("me", "events")

      user_events.each do |event|
        content = Content.new
        content.user_id = current_user.id
        content.external_id = event['id']

        content.body = event['description']
        content.title = event['name']
        content.external_link = "http://facebook.com/"+content.external_id
        # raise event.inspect
        if event['place'].present?
          content.location = event['place']['name'] || ""

          street = event['place']['location']['street']
          city = event['place']['location']['city']
          state = event['place']['location']['state']
          zip = event['place']['location']['zip']
          full_address = street + " " + city + " " + state + " " + zip

          content.address = full_address

          content.longitude = event['place']['location']['longitude']
          content.latitude = event['place']['location']['latitude']
        end

        content.provider = "facebook"
        content.kind = "event"

        content.created_at = event['start_time'] || DateTime.now
        content.active = true

        content.log = event.to_hash

        if (content.valid?)
          content.save!
        end
      end
    end

    def post_multiple_facebook_user_photos(user_client)
      user_photos = user_client.get_connections("me", "photos", {limit: 100})
      user_photos.each do |photo|
        content = Content.new
        content.user_id = current_user.id
        content.external_id = photo['id']

        content.body = photo['name']

        content.provider = "facebook"
        content.kind = "photo"

        content.external_link = "http://facebook.com/" + content.external_id

        content.created_at = photo['created_time'] || DateTime.now
        content.active = true

        content.log = photo.to_hash

        if (content.valid?)
          content.save!
        end
      end
    end

    def post_multiple_facebook_user_family(user_client)
      user_family = user_client.get_connections("me", "family")

      user_family.each do |member|
        content = Content.new
        content.user_id = current_user.id
        content.external_id = member['id']

        content.title = member['relationship']
        content.body = member['name']

        content.provider = "facebook"
        content.kind = "relationship"

        content.external_link = "http://facebook.com/" + content.external_id

        content.created_at = DateTime.now

        content.log = member.to_hash

        if (content.valid?)
          content.save!
        end
      end
    end

# ========================================================
# ============= FITBIT ===================================
# ========================================================
    def set_fitbit_client
      if (user_signed_in? && current_user.identities.where(:provider => "fitbit").present? )
        @@fitbit_client = Fitgem::Client.new({
          consumer_key: ENV["fitbit_key"],
          consumer_secret: ENV["fitbit_secret"],
          token: current_user.identities.where(:provider => "fitbit").first.token,
          secret: current_user.identities.where(:provider => "fitbit").first.secret
        })
      end
    end
    def post_multiple_fitbit_favorite_activities(user_client)
      favorite_activities = user_client.favorite_activities
      favorite_activities.each do |activity|
        content = Content.new
        content.user_id = current_user.id

        content.provider = "fitbit"
        content.kind = "activity"
        content.created_at = DateTime.now
        content.log = activity.to_hash
      end
    end
    def post_multiple_fitbit_activities(user_client)
      user_activity = user_client.recent_activities
      user_activity.each do |activity|
        # raise activity.inspect
        content = Content.new
        content.user_id = current_user.id
        content.external_id = activity["activityId"]
        content.title = activity["name"]
        content.body = activity["description"].to_s + " Calories:" + activity["calories"].to_s + " Duration:" + activity["duration"].to_s + " Distance:" + activity["distance"].to_s
        content.active = true
        content.external_link = "#"
        content.provider = "fitbit"
        content.kind = "activity"
        content.created_at = DateTime.now
        content.log = activity.to_hash

        if (content.valid?)
          content.save!
        end
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
    def post_multiple_foursquare_checkins(user_client)
      user_checkins = user_client.user_checkins.items
      user_checkins.each do |checkin|
        content = Content.new
        content.user_id = current_user.id

        # raise checkin.inspect
        content.external_id = checkin.id
        content.body = checkin.shout
        content.title = checkin.venue.name

        content.longitude = checkin.venue.location.lng
        content.latitude = checkin.venue.location.lat

        address = checkin.venue.location.formattedAddress[0].to_s + " " + checkin.venue.location.formattedAddress[1].to_s
        content.address = address

        content.active = true
        content.external_link = "#"
        # content.external_link = "http://foursquare.com/user/"+ user.id

        created_at = Time.at(checkin.createdAt).utc.to_datetime
        content.created_at = created_at
        content.provider = "foursquare"
        content.kind = "checkin"

        content.log = checkin.to_hash
        if checkin.photos.items.first.present?
          content.image = checkin.photos.items.first
        end

        if (content.valid?)
          content.save!
        end
      end
    end
    def post_multiple_foursquare_user_friends(user_client)
      user_friends = user_client.user_friends('self').items
      # raise user_friends.inspect
      user_friends.each do |friend|
        content = Content.new

        content.user_id = current_user.id
        content.external_id = friend.id

        content.title = friend.relationship
        content.body = friend.firstName + " " + friend.lastName
        content.location = friend.homeCity

        content.created_at = DateTime.now
        content.provider = "foursquare"
        content.kind = "friend"
        content.log = friend.to_hash

        if (content.valid?)
          content.save!
        end
      end
    end

# ========================================================
# ============= TWITTER =================================
# ========================================================
    def set_twitter_client
      if (user_signed_in? && current_user.identities.where(:provider => "twitter").present? )
        @@twitter_client ||= Twitter::REST::Client.new do |config|
          config.consumer_key = ENV['twitter_key']
          config.consumer_secret = ENV['twitter_secret']
          config.access_token = current_user.identities.where(:provider => "twitter").first.token
          config.access_token_secret = current_user.identities.where(:provider => "twitter").first.secret
        end
      end
    end

    def user_timeline(user_client, qt)
      user_client.user_timeline(count: qt)
    end

    def post_multiple_tweets(user_client, count)
      # GET A USER'S TIMELINE GOING BACK AS FAR AS COUNT
      user_tweets = user_client.user_timeline(count: count)
      # LOOP THROUGH EACH TWEET IN USER TIMELINE AND CREATE 'NEW CONTENT'
      user_tweets.each do |tweet|
        content = Content.new

        content.user_id = current_user.id
        content.external_id = tweet.id
        content.body = tweet.text

        content.longitude = tweet.place.bounding_box.coordinates[0][0][0]
        content.latitude = tweet.place.bounding_box.coordinates[0][0][1]
        content.active = true
        content.external_link = tweet.url

        content.created_at = tweet.created_at || DateTime.now
        content.provider = "twitter"
        content.kind = "tweet"

        content.log = tweet.to_hash
        if tweet.media.present?
          content.image = tweet.media[0].media_url
        end

        if (content.valid?)
          content.save!
        end
      end
    end

end
