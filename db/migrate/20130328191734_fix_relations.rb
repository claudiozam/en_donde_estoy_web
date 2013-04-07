class FixRelations < ActiveRecord::Migration
  def up
  	remove_column :devices, :location_id
  end

  def down
  	add_column :devices, :location_id, :integer
  end
end
