class Location < ActiveRecord::Base
  has_many :location_points
  has_one :current_location_point, :class_name => 'LocationPoint', :foreign_key => 'current_location_point_id', :primary_key => 'id'
	has_one :device
	belongs_to :location_category
	belongs_to :location_type
  attr_accessible :description
	
	scope :with_category, lambda{ |value| include(:location_category).where("location_category.name like ?", '%'+value+'%') unless value.blank? }
	scope :with_device_name, lambda{ |value| include(:device).merge(Device.with_name(value)) unless value.blank? }
	scope :near_location_points, lambda{ |latitude, longitude| joins(:location_points).merge(LocationPoint.near_location(latitude, longitude)) }
end
