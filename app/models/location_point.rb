class LocationPoint < ActiveRecord::Base
  geocoded_by :address
	
	belongs_to :locations 

	attr_accessible :device_id, :latitude, :longitude
	validates :latitude, :presence => true, :numericality => true
	validates :longitude, :presence => true, :numericality => true

	def get_address
		results = Geocoder.search([latitude, longitude].join(','))
	end
end
