class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.references :content, index: true
      t.string :name

      t.timestamps null: false
    end
    add_foreign_key :tags, :contents
  end
end
