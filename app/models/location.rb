class Location < ActiveRecord::Base
  	has_many :location_points
	belongs_to :location_point
	has_one :current_location_point, :class_name => 'LocationPoint', :foreign_key => 'current_location_id'
	belongs_to :device
	belongs_to :location_category
	belongs_to :location_type
  	attr_accessible :description
	
	scope :with_category, lambda{ |value| joins(:location_category).where("name like ?", '%'+value+'%') if (not value.blank? and value!="all") }
	scope :with_device_name, lambda{ |value| joins(:device).merge(Device.with_name(value)) unless value.blank? }
	scope :near_location_points, lambda{ |latitude, longitude| joins(:location_points).merge( LocationPoint.near_location(latitude, longitude) ) }
end
