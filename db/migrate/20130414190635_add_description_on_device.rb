class AddDescriptionOnDevice < ActiveRecord::Migration
  def up
  	add_column :devices, :description, :text
  end

  def down
  	remove_column :devices, :description
  end
end
