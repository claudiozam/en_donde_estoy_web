class LocationCategory < ActiveRecord::Base
  has_many :locations
  attr_accessible :name
end
