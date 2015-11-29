class Content < ActiveRecord::Base
  belongs_to :user
  validates :external_id, uniqueness: true , :allow_blank => true, :allow_nil => true
  # has_one :twitter_tweet, through: :contents
  # has_one :facebook_post

  def self.to_csv
    # CREATES AN ARRAY OF STRINGS "ID", "TITLE"..
    attributes = %w{id created_at title body provider kind log}
    CSV.generate(headers:true) do |csv|
      # PUSHES ATTRIBUTES INTO FIRST ROW
      csv << attributes

      all.each do |content|
        # raise content.inspect
        csv << content.attributes.values_at(*attributes)
      end
    end
  end

# ========================================================
# ============= FACEBOOK =================================
# ========================================================
  def post_multiple_facebook_posts(user_client, user)
    user_timeline = user_client.get_connections("me", "feed", {limit: 100})
    user_timeline.each do |post|
      content = Content.new
      content.user_id = user
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
  def post_multiple_facebook_user_likes(user_client, user)
    user_likes = user_client.get_connections("me", "likes")

    user_likes.each do |like|
      content = Content.new
      content.user_id = user
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
  def post_multiple_facebook_user_events(user_client, user)
    user_events = user_client.get_connections("me", "events")

    user_events.each do |event|
      content = Content.new
      content.user_id = user
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

  def post_multiple_facebook_user_photos(user_client, user)
    user_photos = user_client.get_connections("me", "photos", {limit: 100})
    user_photos.each do |photo|
      content = Content.new
      content.user_id = user
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

  def post_multiple_facebook_user_family(user_client, user)
    user_family = user_client.get_connections("me", "family")

    user_family.each do |member|
      content = Content.new
      content.user_id = user
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
  def post_multiple_fitbit_favorite_activities(user_client, user)
    favorite_activities = user_client.favorite_activities
    favorite_activities.each do |activity|
      content = Content.new
      content.user_id = user

      content.provider = "fitbit"
      content.kind = "activity"
      content.created_at = DateTime.now
      content.log = activity.to_hash
    end
  end
  def post_multiple_fitbit_activities(user_client, user)
    user_activity = user_client.recent_activities
    user_activity.each do |activity|
      # raise activity.inspect
      content = Content.new
      content.user_id = user
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
  def post_multiple_foursquare_checkins(user_client, user)
    user_checkins = user_client.user_checkins.items
    user_checkins.each do |checkin|
      content = Content.new
      content.user_id = user

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
  def post_multiple_foursquare_user_friends(user_client,user)
    user_friends = user_client.user_friends('self').items
    # raise user_friends.inspect
    user_friends.each do |friend|
      content = Content.new

      content.user_id = user
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
# ============= GITHUB ===================================
# ========================================================
  def post_multiple_github_repos(user_client, user)
    user_repos = user_client.repos.list
    user_repos.each do |repo|
      content = Content.new
      content.user_id = user
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
        post_multiple_github_commits(repo_commits, content.id, user)
      end

      if (content.valid?)
        content.save!
      end
    end
  end
  def post_multiple_github_commits(repo_commits, parent_repo_id, user)
    repo_commits.each do |commit|
      puts "COMMIT ID: " + commit.sha
      commit_content = Content.new
      commit_content.user_id = user
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
# ============= TWITTER ==================================
# ========================================================
  def post_multiple_tweets(user_client,user, count)
    # GET A USER'S TIMELINE GOING BACK AS FAR AS COUNT
    user_tweets = user_client.user_timeline(count: count)
    # LOOP THROUGH EACH TWEET IN USER TIMELINE AND CREATE 'NEW CONTENT'
    user_tweets.each do |tweet|
      content = Content.new

      content.user_id = user
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
