json.array! @all_fitbitContent.order('created_at ASC') do |event|
  json.id event.id
  json.body event.body
  json.datetime event.created_at
end
