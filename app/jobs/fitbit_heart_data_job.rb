class FitbitHeartDataJob < ActiveJob::Base
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)

    if (user.identities.where(:provider => "fitbit_oauth2").present? )
      @@fitbit_client =  Fitbit::Client.new(
        client_id: ENV["fitbit_client_id"],
        client_secret: ENV["fitbit_secret"],
        access_token: user.identities.where(:provider => "fitbit_oauth2").first.token,
        refresh_token: user.identities.where(:provider => "fitbit_oauth2").first.refresh_token,
        expires_at: user.identities.where(:provider => "fitbit_oauth2").first.expires_at
      )
    end

    if Content.where(:user_id => user.id).present?
      lastDate = Content.where(:user_id => user.id).order('created_at DESC').first.created_at.day
    else
      lastDate = Date.today.day - 1
    end

    pullDays = Date.today.day - lastDate

    days_ago = 0
    if pullDays.present?
      days_to = pullDays + 1
    else
      days_to = 5
    end

    full_heart_date = []

    # THIS PULLS DATA FROM FITBIT FOR THE NUMBER OF DAYS SET BELOW
    while days_ago < days_to do
      user_daily_heartrate = @@fitbit_client.heart_rate_intraday_time_series(date: Date.today - days_ago, detail_level:"1min").inspect

      parsed_heart =  JSON.parse user_daily_heartrate.gsub('=>', ':')
      parsed_heart_filtered = parsed_heart['activities-heart-intraday']['dataset']

      full_heart_date.push(parsed_heart_filtered)
      days_ago += 1
    end

    dayCount = 0
    # EACH DAY IN full_heart_data
    full_heart_date.each do |day|
      dayIndex = 1
      # EACH EVENT IN full_heart_data DAY
      day.each do |event|
        @content = Content.new
        # PASS IN EVENT, INDEX2 (REPRESENTS THE DAY OF WHICH HAPPENED DateTime.now - Index2)
        @content.post_fitbit_intraday_heart(event, dayCount, dayIndex, user.id)
        dayIndex += 1
      end
      dayCount += 1
    end

    Notification.create(recipient: user, action: "Updated all Fitbit Content")
  end
end
