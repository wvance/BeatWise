class Content < ActiveRecord::Base
  searchkick

  belongs_to :user
  validates :external_id, uniqueness: true , :allow_blank => true, :allow_nil => true
  # has_one :twitter_tweet, through: :contents
  # has_one :facebook_post
  # after_commit :post_tweet

  def self.to_csv
    # CREATES AN ARRAY OF STRINGS "ID", "TITLE"..
    attributes = %w{id provider kind created_at title body longitude latitude external_link log}
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
  def post_facebook_post(post, user)
    self.user_id = user
    self.external_id = post['id']
    self.body = post['message']
    self.provider = "facebook"
    self.kind = "post"
    self.external_link = "http://facebook.com/" + self.external_id

    self.created_at = post['created_time'] || DateTime.now
    self.active = true

    self.log = post.to_hash

    if (self.valid?)
      self.save!
    else
      # raise self.errors.inspect
    end
  end
  def post_facebook_user_like(like, user)
    self.user_id = user
    self.external_id = like['id']
    self.body = like['name']

    self.external_link = "http://facebook.com/" + self.external_id
    self.provider = "facebook"
    self.kind = "like"

    self.created_at = like['created_time'] || DateTime.now
    self.active = true

    self.log = like.to_hash

    if (self.valid?)
      self.save!
    else
      # raise self.errors.inspect
    end
  end
  def post_facebook_user_event(event, user)
    self.user_id = user
    self.external_id = event['id']

    self.body = event['description']
    self.title = event['name']
    self.external_link = "http://facebook.com/"+self.external_id
    # raise event.inspect
    if event['place'].present?
      self.location = event['place']['name'] || ""

      street = event['place']['location']['street']
      city = event['place']['location']['city']
      state = event['place']['location']['state']
      zip = event['place']['location']['zip']
      full_address = street + " " + city + " " + state + " " + zip

      self.address = full_address

      self.longitude = event['place']['location']['longitude']
      self.latitude = event['place']['location']['latitude']
    end

    self.provider = "facebook"
    self.kind = "event"

    self.created_at = event['start_time'] || DateTime.now
    self.active = true

    self.log = event.to_hash

    if (self.valid?)
      self.save!
    else
      # raise self.errors.inspect
    end
  end

  def post_facebook_user_photo(photo, user)
    self.user_id = user
    self.external_id = photo['id']

    self.body = photo['name']

    self.provider = "facebook"
    self.kind = "photo"

    self.external_link = "http://facebook.com/" + self.external_id

    self.created_at = photo['created_time'] || DateTime.now
    self.active = true

    self.log = photo.to_hash
    if (self.valid?)
      self.save!
    else
      # raise self.errors.inspect
    end
  end

  def post_facebook_user_family(member, user)
    self.user_id = user
    self.external_id = member['id']

    self.title = member['relationship']
    self.body = member['name']

    self.provider = "facebook"
    self.kind = "relationship"

    self.external_link = "http://facebook.com/" + self.external_id

    self.created_at = DateTime.now

    self.log = member.to_hash

    if (self.valid?)
      self.save!
    else
      # raise self.errors.inspect
    end
  end


# ========================================================
# ============= FOURSQUARE ===============================
# ========================================================
  def post_foursquare_checkin(checkin, user)
    # content = Content.new
    self.user_id = user

    # raise checkin.inspect
    self.external_id = checkin.id
    self.body = checkin.shout
    self.title = checkin.venue.name

    self.longitude = checkin.venue.location.lng
    self.latitude = checkin.venue.location.lat

    address = checkin.venue.location.formattedAddress[0].to_s + " " + checkin.venue.location.formattedAddress[1].to_s
    self.address = address

    self.active = true
    self.external_link = "#"
    # content.external_link = "http://foursquare.com/user/"+ user.id

    created_at = Time.at(checkin.createdAt).utc.to_datetime
    self.created_at = created_at
    self.provider = "foursquare"
    self.kind = "checkin"

    self.log = checkin.to_hash
    if checkin.photos.items.first.present?
      self.image = checkin.photos.items.first['prefix'] + "800x800" + checkin.photos.items.first['suffix']
    end

    if (self.valid?)
      self.save!
    else
      # raise self.errors.inspect
    end
  end
  def post_foursquare_user_friend(friend, user)
    # content = Content.new
    self.user_id = user
    self.external_id = friend.id

    self.title = friend.relationship
    self.body = friend.firstName + " " + friend.lastName
    self.location = friend.homeCity

    self.created_at = DateTime.now
    self.provider = "foursquare"
    self.kind = "friend"
    self.log = friend.to_hash

    if (self.valid?)
      self.save!
    else
      # raise self.errors.inspect
    end
  end

# ========================================================
# ============= TWITTER ==================================
# ========================================================
  def post_tweet(tweet, user)
    self.user_id = user
    self.external_id = tweet.id
    self.body = tweet.text

    self.longitude = tweet.place.bounding_box.coordinates[0][0][0]
    self.latitude = tweet.place.bounding_box.coordinates[0][0][1]
    self.active = true
    self.external_link = tweet.url

    self.created_at = tweet.created_at || DateTime.now
    self.provider = "twitter"
    self.kind = "tweet"

    self.log = tweet.to_hash
    if tweet.media.present?
      self.image = tweet.media[0].media_url
    end

    if (self.valid?)
      self.save!
    else
      # raise self.errors.inspect
    end
  end
# ========================================================
# ============= GITHUB ===================================
# ========================================================
  def post_github_repo(repo, user)
    self.user_id = user
    self.external_id = repo.id

    self.title = repo.full_name
    self.body = repo.description
    self.external_link = repo.html_url

    self.provider = "github"
    self.kind = "repo"

    self.created_at = repo.created_at || DateTime.now
    self.active = true
    self.log = repo.to_hash

    # GET REPO COMMITS FROM THE CURRENT REPO: CALL FUNCTION TO SAVE THOSE
    # HOW TO CHECK IF THIS IS EMPTY???
    # raise user_client.repos.commits.list(repo.owner.login, repo.name).inspect

    # if user_client.repos.commits.list(repo.owner.login, repo.name)
    #   repo_commits = user_client.repos.commits.list(repo.owner.login, repo.name)

    #   repo_commits.each do |commit|
    #     post_github_commit(commit, self.id, user)
    #   end
    # end
    if (self.valid?)
      self.save!
    else
      # raise self.errors.inspect
    end
  end

  def post_github_commit(commit, parent_repo_id, user)
    self.user_id = user
    self.external_id = commit.sha

    self.title = commit.commit.author.name
    self.body = commit.commit.message
    self.external_link = commit.html_url

    self.provider = "github"
    self.kind = "commit"
    self.active = true

    self.created_at = commit.commit.author.date || DateTime.now
    self.parent = parent_repo_id
    self.log = commit.to_hash

    if (self.valid?)
      self.save!
    else
      # raise self.errors.inspect
    end
  end

# ========================================================
# ============= FITBIT ===================================
# ========================================================
  def post_fitbit_favorite_activity(activity, user)
    self.user_id = user

    self.provider = "fitbit"
    self.kind = "activity"
    self.created_at = DateTime.now
    self.log = activity.to_hash

    if (self.valid?)
      self.save!
    else
    end
  end
  def post_fitbit_recent_activity(activity, user)
    self.user_id = user
    self.external_id = activity["activityId"]
    self.title = activity["name"]
    self.body = activity["description"].to_s + " Calories:" + activity["calories"].to_s + " Duration:" + activity["duration"].to_s + " Distance:" + activity["distance"].to_s
    self.active = true
    self.external_link = "#"
    self.provider = "fitbit"
    self.kind = "activity"
    self.created_at = DateTime.now
    self.log = activity.to_hash

    if (self.valid?)
      self.save!
    else
    end
  end

  def post_fitbit_daily_sleep_log(day, user)
    self.user_id = user
    self.external_id = day['logId']
    self.body = day['timeInBed']
    self.active = true
    self.external_link = "#"
    self.provider = "fitbit"
    self.kind = "sleep"

    self.created_at = day['startTime']
    self.log = day.to_hash

    if (self.valid?)
      self.save!
    else
    end
  end

  def post_fitbit_daily_sleep(day, user)
    self.user_id = user
    self.external_id = "daily_sleep" + day['dateTime']
    self.body = day['value']
    self.active = true
    self.external_link = "#"
    self.provider = "fitbit"
    self.kind = "asleep"

    self.created_at = day['dateTime']
    self.log = day.to_hash

    if (self.valid?)
      self.save!
    else
    end
  end

  def post_fitbit_daily_heart_rate(day, user)
    self.user_id = user
    self.external_id = "daily_heart_overview" + day['dateTime']
    self.body = day['value']
    self.active = true
    self.external_link = "#"
    self.provider = "fitbit"
    self.kind = "heartrate"

    self.created_at = day['dateTime']
    self.log = day.to_hash

    if (self.valid?)
      self.save!
    else
    end
  end

  # GEO INFO
  # if (self.ip.present?)
  #   geocoded_by :ip, :latitude => :latitude, :longitude => :longitude
  # end

  geocoded_by :location ,
    :latitude => :Latitude, :longitude => :Longitude


  reverse_geocoded_by :latitude, :longitude do |obj,results|
    if geo = results.first
      # CITY, STATE, COUNTRY & POSTAL CODE SEPERATE
      obj.city = geo.city
      obj.state = geo.state_code
      obj.country = geo.country_code
      obj.postal = geo.postal_code

      # FULL ADDRESS
      if geo.address
        obj.address = geo.address
      else
        obj.address = geo.city + " " + geo.state_code + " " + geo.country_code + " " + geo.postal_code
        if obj.location.present?
          obj.location = obj.address
        end
      end
    end
  end

  unless :latitude.present? && :longitude.present?
    after_validation :geocode, if: ->(obj){ obj.location.present? }
  end

  after_validation :reverse_geocode, if: ->(obj){ obj.longitude.present? and obj.latitude.present? }

end
