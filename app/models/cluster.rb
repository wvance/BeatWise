class Cluster < ActiveRecord::Base
  belongs_to :user

  def create_clusters(day_content)
    # day_content is a hash of a single days day content
    # TAKE IN DAY AND CREATE A CLUSTER
  end
end
