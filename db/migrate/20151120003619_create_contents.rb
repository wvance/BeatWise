class CreateContents < ActiveRecord::Migration
  def change
    create_table :contents do |t|
      t.references :user, index: true
      t.string :title
      t.string :body
      t.string :parent

      t.string :location

      t.string :address
      t.string :city
      t.string :state
      t.string :postal
      t.string :country

      t.string :latitude
      t.string :longitude

      t.string :external_id
      t.string :external_link

      t.string :image
      t.string :kind
      t.string :provider

      t.text :log

      t.boolean :active
      t.timestamps null: false
    end
    add_foreign_key :contents, :users
  end
end
