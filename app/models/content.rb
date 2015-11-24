class Content < ActiveRecord::Base
  belongs_to :user
  validates :external_id, uniqueness: true , :allow_blank => true, :allow_nil => true
  # has_one :twitter_tweet, through: :contents
  #has_one :facebook_post

  def self.to_csv
    # CREATES AN ARRAY OF STRINGS "ID", "TITLE"..
    attributes = %w{id created_at title body provider kind log}
    CSV.generate(headers:true) do |csv|
      # PUSHES ATTRIBUTES INTO FIRST ROW
      csv << attributes

      all.each do |content|
        # raise content.inspect
        csv << content.attributes.values_at(*attributes)
      end
    end
  end
end
