class FoursquareDataJob < ActiveJob::Base
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)
    if (user.identities.where(:provider => "foursquare").present? )
      @@foursquare_client = Foursquare2::Client.new(:oauth_token => user.identities.where(:provider => "foursquare").first.token, :api_version => '20140806')

      user_checkins = @@foursquare_client.user_checkins(:limit=>200).items
      user_checkins.each do |checkin|
        @content = Content.new
        @content.post_foursquare_checkin(checkin, user.id)
      end
    end
  end
end
