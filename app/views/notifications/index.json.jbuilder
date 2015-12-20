json.array! @notifications do |notification|
  json.id notification.id
  json.action notification.action
  json.created_at notification.created_at
  json.notifiable do
    json.type "a #{notification.notifiable.class.to_s.underscore.humanize.downcase}"
  end
end
