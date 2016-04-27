class CreateClustercomparisons < ActiveRecord::Migration
  def change
    create_table :clustercomparisons do |t|
      t.cluster :references
      t.cluster :references
      t.float :score

      t.timestamps null: false
    end
  end
end
