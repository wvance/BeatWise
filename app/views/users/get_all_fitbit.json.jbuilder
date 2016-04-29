json.array! @fitbitContent do |event|
  json.id event.id
  json.body event.body
  json.datetime event.created_at
end
