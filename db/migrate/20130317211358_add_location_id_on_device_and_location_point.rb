class AddLocationIdOnDeviceAndLocationPoint < ActiveRecord::Migration
  def up
  	add_column :devices, :location_id, :integer
  	add_column :location_points, :location_id, :integer
  end

  def down
  	remove_column :devices, :location_id
  	remove_column :location_points, :location_id
  end
end
