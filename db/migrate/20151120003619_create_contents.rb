class CreateContents < ActiveRecord::Migration
  def change
    create_table :contents do |t|
      t.references :user, index: true
      t.string :location
      t.string :address
      t.string :latitude
      t.string :longitude
      t.integer :external_id, :limit => 8
      t.string :external_link
      t.string :title
      t.string :body
      t.integer :number_retweets
      t.integer :number_likes
      t.string :image
      t.string :kind
      t.string :provider


      t.boolean :active
      t.timestamps null: false
    end
    add_foreign_key :contents, :users
  end
end
