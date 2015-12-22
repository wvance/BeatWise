class FacebookDataJob < ActiveJob::Base
  queue_as :default
  # TAKES 30 SECONDS OR SO?
  def perform(user_id, post_count, photo_count)
    user = User.find(user_id)
    if (user.identities.where(:provider => "facebook").present?)

      Koala.config.api_version = "v2.0"
      @@facebook_client = Koala::Facebook::API.new(user.identities.where(:provider => "facebook").first.token)


      user_timeline = @@facebook_client.get_connection('me', 'posts',
        {limit: post_count,
          fields: ['message', 'id', 'from', 'type', 'status_type', 'shares',
            'picture', 'link', 'created_time', 'place', 'likes', 'comments'
        ]})
      count = 0;

      user_timeline.each do |post|
        @content = Content.new
        @content.post_facebook_post(post, user.id)
      end


      # ISSUES RIGHT NOW?

      # user_events = @@facebook_client.get_connections("me", "events")
      # user_events.each do |event|
      #   @content = Content.new
      #   @content.post_facebook_user_event(event, user.id)
      # end
      user_photos = @@facebook_client.get_connection('me', 'photos',
        {limit: photo_count,
          fields: ['message', 'id', 'from', 'type', 'status_type', 'shares',
            'picture', 'link', 'created_time', 'place', 'likes', 'comments'
        ]})
      user_photos.each do |photo|
        @content = Content.new
        @content.post_facebook_user_photo(photo, user.id)
      end
    end
    Notification.create(recipient: user, action: "Updated all Facebook Content ")
  end
end

# HOW TO CALL :D
# NOTES: RUNS ON DEFAUT QUEUE
# FacbookDataJob.perform_now user_id (vs current_user)
# OR
# FacebookDataJob.perform_later user_id

# Passing in user_object: Remember, dont know when...
