class AddCurrentLocationPointIdToLocationPoint < ActiveRecord::Migration
  def up
  	add_column :location_points, :current_location_point_id, :integer 
  end

  def down
  	remove_column :location_points, :current_location_point_id
  end
end
