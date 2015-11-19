class CreateIdentities < ActiveRecord::Migration
  def change
    create_table :identities do |t|
      t.references :user, index: true
      t.string :provider
      t.string :uid
      t.string :token
      t.string :secret

      t.timestamps null: false
    end
    add_foreign_key :identities, :users
  end
end
