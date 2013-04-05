# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


# Location.delete_all!
# LocationCategory.delete_all!
# LocationType.delete_all!
# LocationPoint.delete_all!
# Device.delete_all


# We set default location_category:
["Comercio","Instituto","Taxi","Colectivo"].each do |nombre|
	lc = LocationCategory.new :name => nombre
	lc.save
end

# We set default location_type:
lc = LocationType.new :name => "Supermercardo", :dinamic => false
lc.save

lc2 = LocationType.new :name => "Transporte", :dinamic => true
lc2.save


