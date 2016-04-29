class FitbitTagJob < ActiveJob::Base
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)

    # GETS ALL THE CONTENT FROM THE USER
    @content = Content.where(:user_id => user.id)
    # ADD TAGS TO ALL THE CONTENT
    @content.add_tags(user.id)

    Notification.create(recipient: user, action: "Added Tags to Content")
  end
end
