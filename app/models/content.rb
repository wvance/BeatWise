class Content < ActiveRecord::Base
  belongs_to :user
  validates :external_id, uniqueness: true , :allow_blank => true, :allow_nil => true
  # has_one :twitter_tweet, through: :contents
  #has_one :facebook_post
end
