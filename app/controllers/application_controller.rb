class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :set_twitter_client
  before_action :set_foursquare_client

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
    def set_foursquare_client
      if (user_signed_in? && current_user.identities.where(:provider => "foursquare").present? )
        @@foursquare_client = Foursquare2::Client.new(:oauth_token => current_user.identities.where(:provider => "foursquare").first.token, :api_version => '20140806')
      end
    end
    def user_checkins(user_client)
      raise user_client.user_checkins.items.inspect
    end
    def post_multiple_foursquare_checkins(user_client)
      user_checkins = user_client.user_checkins.items

      user_checkins.each do |checkin|
        content = Content.new
        content.user_id = current_user.id

        # raise checkin.inspect

        content.external_id = checkin.id
        content.body = checkin.text
        content.title = checkin.venue.name

        content.longitude = checkin.venue.location.lng
        content.latitude = checkin.venue.location.lat

        address = checkin.venue.location.formattedAddress[0].to_s + " " + checkin.venue.location.formattedAddress[1].to_s
        content.address = address

        content.active = true
        content.external_link = ""
        # content.external_link = "http://foursquare.com/user/"+ user.id

        content.created_at = DateTime.now
        content.kind = "foursquareCheckin"

        if checkin.photos.items.first.present?
          content.image = checkin.photos.items.first
        end

        if (content.valid?)
          content.save!
        end
      end
    end


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

        content.created_at = DateTime.now
        content.kind = "tweet"

        if tweet.media.present?
          content.image = tweet.media[0].media_url
        end

        if (content.valid?)
          content.save!
        end
      end
    end

end
