class Device < ActiveRecord::Base
  has_one :location
  has_many :location_points, :through => :locations 
  attr_accessible :name


	scope :with_name, lambda{ |value| where("device.name like ?", '%'+value+'%') unless value.blank? }
end
