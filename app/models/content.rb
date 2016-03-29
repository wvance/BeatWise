class Content < ActiveRecord::Base
  # ENABLES ELASTICSEARCH FOR THIS CLASS
  # searchkick
  belongs_to :user
  validates :external_id, uniqueness: true , :allow_blank => true, :allow_nil => true

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

# ========================================================
# ============= GEOCODER =================================
# ========================================================
# GETS CONTENT LOCATION AND LONG LAT

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
