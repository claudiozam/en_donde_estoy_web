class CreateLocationTypes < ActiveRecord::Migration
  def change
    create_table :location_types do |t|
      t.string :name
      t.boolean :dinamic
      t.text :description

      t.timestamps
    end
  end
end
