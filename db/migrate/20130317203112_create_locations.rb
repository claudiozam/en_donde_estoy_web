class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.integer :location_type_id
      t.integer :location_category_id
      t.integer :current_location_point_id
      t.integer :device_id
      t.timestamps
    end
  end
end
