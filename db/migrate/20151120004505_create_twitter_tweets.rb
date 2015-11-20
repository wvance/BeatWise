class CreateTwitterTweets < ActiveRecord::Migration
  def change
    create_table :twitter_tweets do |t|
      t.references :content, index: true
      t.string :body
      t.integer :number_retweets
      t.integer :number_likes
      t.string :image

      t.timestamps null: false
    end
    add_foreign_key :twitter_tweets, :contents
  end
end
