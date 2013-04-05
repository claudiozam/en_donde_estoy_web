class FixRelationsBetweenLocationAndCurrentPoint < ActiveRecord::Migration
  def up
  	rename_column :location_points, :current_location_point_id , :current_location_id 
  	remove_column :locations, :current_location_point_id
  end

  def down
  	rename_column :location_points, :current_location_id , :current_location_point_id 
  	add_column :locations, :current_location_point_id, :integer
  end
end
