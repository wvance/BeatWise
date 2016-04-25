class CreateClusters < ActiveRecord::Migration
  def change
    create_table :clusters do |t|
      t.date :date
      t.references :user, index: true

      t.integer :minimum
      t.integer :maximum
      t.string :average
      t.string :average_slope

      t.timestamps null: false
    end
  end
end
