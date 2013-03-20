class Device < ActiveRecord::Base
  has_one :location
  has_many :location_points, :through => :locations 
  attr_accessible :name
end
