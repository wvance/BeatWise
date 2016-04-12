json.array! current_user.contents.where(:provider => "fitbit").where('created_at >= ?', (Date.yesterday).to_datetime).where('created_at <= ?', (Date.today).to_datetime).all do |event|
  json.body event.body
  json.seconds event.created_at.strftime("%S")
  json.minuites event.created_at.strftime("%M")
  json.hour event.created_at.strftime("%k")

  json.day event.created_at.strftime("%-d")
  json.month event.created_at.strftime("%-m")
  json.year event.created_at.strftime("%y")
end
