json.array! @fitbitContent do |event|
  json.body event.body
  json.seconds event.created_at.strftime("%S")
  json.minuites event.created_at.strftime("%M")
  json.hour event.created_at.strftime("%H")

  json.tag event.tag

  json.day event.created_at.strftime("%-d")
  json.month event.created_at.strftime("%-m")
  json.year event.created_at.strftime("%y")
end
