class CreateAzhpcclusters < ActiveRecord::Migration[5.2]
  def change
    create_table :azhpcclusters do |t|
      t.string :name
      t.string :status
      t.string :sku
      t.string :scheduler
      t.string :arch
      t.string :config
      t.integer :nodecount
      t.integer :corecount
      t.text :description
      t.datetime :created_at
      t.datetime :updated_at

      t.timestamps
    end
  end
end
