class GithubDataJob < ActiveJob::Base
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)
    if (user.identities.where(:provider => "github").present? )
      @@github_client = Github.new :oauth_token => user.identities.where(:provider => "github").first.token

      user_repos = @@github_client.repos.list

      user_repos.each do |repo|
        @content = Content.new
        @content.post_github_repo(repo, user.id)
      end
    end
    Notification.create(recipient: user, action: "Updated all Github Content")
  end
end
