class FitbitDataJob < ActiveJob::Base
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)
    if (user.identities.where(:provider => "fitbit_oauth2").present? )
      @@fitbit_client = Fitbit::Client.new(
        ENV["fitbit_client_id"],
        ENV["fitbit_secret"],
        user.identities.where(:provider => "fitbit_oauth2").first.token
      )
      user_activity = @@fitbit_client.recent_activities
      user_activity.each do |activity|
        @content = Content.new
        @content.post_fitbit_recent_activity(activity, user.id)
      end

      favorite_activities = @@fitbit_client.favorite_activities
      favorite_activities.each do |activity|
        @content = Content.new
        @content.post_fitbit_favorite_activity(activity, user.id)
      end

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
          @content.post_fitbit_daily_sleep_log(sleep_log, user.id)
        end
      end

      heart_rates = @@fitbit_client.heart_rate_time_series(date: today, period: '1d')
      heart_rates = heart_rates['activities-heart']

      heart_rates.each do |day|
        @content = Content.new
        @content.post_fitbit_daily_heart_rate(day, user.id)
      end
    end
    Notification.create(recipient: user, action: "Updated all Fitbit Content")
  end
end
