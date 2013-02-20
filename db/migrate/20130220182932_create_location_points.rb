class CreateLocationPoints < ActiveRecord::Migration
  def change
    create_table :location_points do |t|
      t.float :latitude
      t.float :longitude
      t.integer :device_id

      t.timestamps
    end

    add_index :location_points, [:latitude, :longitude]
    add_index :location_points, [:created_at]
  end
end
