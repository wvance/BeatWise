class TwitterDataJob < ActiveJob::Base
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)
    if (user.identities.where(:provider => "twitter").present? )
      @@twitter_client ||= Twitter::REST::Client.new do |config|
        config.consumer_key = ENV['twitter_key']
        config.consumer_secret = ENV['twitter_secret']
        config.access_token = user.identities.where(:provider => "twitter").first.token
        config.access_token_secret = user.identities.where(:provider => "twitter").first.secret
      end
    end

    user_tweets = @@twitter_client.user_timeline(count: 100)

    user_tweets.each do |tweet|
      @content = Content.new
      @content.post_tweet(tweet, user.id)
    end

    Notification.create(recipient: user, action: "Updated all Twitter Content")
  end
end
