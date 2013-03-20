class Location < ActiveRecord::Base
  has_many :location_points
  has_one :current_location_point, :class_name => 'LocationPoints', :foreign_key => 'current_location_point_id'
	belongs_to :location_category
	belongs_to :location_type
	has_one :device

  attr_accessible :description
end
