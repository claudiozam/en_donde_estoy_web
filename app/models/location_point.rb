class LocationPoint < ActiveRecord::Base
  geocoded_by :address
	
	belongs_to :location

	attr_accessible :device_id, :latitude, :longitude

	validates :latitude, :presence => true, :numericality => true
	validates :longitude, :presence => true, :numericality => true
	
	scope :is_current, where("current_location_id IS NOT NULL")
	scope :near_location, lambda{ |latitude, longitude| LocationPoint.near([latitude, longitude], 5, :units => :km) }
	
	def get_address
		results = Geocoder.search([latitude, longitude].join(','))
	end
end
