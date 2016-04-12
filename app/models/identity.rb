class Identity < ActiveRecord::Base
  belongs_to :user

  # MAKE SURE THERE IS A UID PROVIDED AND THE UID + PROVIDER ARE UNIQUE
  validates_presence_of :uid, :provider
  validates_uniqueness_of :uid, :scope => :provider

  def self.find_for_oauth(auth)
    email_is_verified = auth.info.email
    email = auth.info.email if email_is_verified
    find_or_create_by(
      uid: auth.uid,
      provider: auth.provider,
      token: auth.credentials.token,
      refresh_token: auth.credentials.refresh_token,
      expires_at: auth.credentials.expires_at,
      secret: auth.credentials.secret,
      username: auth.info.nickname || auth.info.full_name || auth.info.name || auth.uid,
      email: email ? email : "#{auth.uid}-#{auth.provider}.com",
      # identity_log: auth.to_json
      )
  end
end
