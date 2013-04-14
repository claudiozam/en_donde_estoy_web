# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# We set default location_category:
["personal","comercio","instituto","taxi","colectivo"].each do |nombre|
	lc = LocationCategory.new :name => nombre
	lc.save
end

# We set default location_type:
["establecimiento","movil"].each do |nombre|
	lt = LocationType.new :name => nombre
	lt.dinamic = false
	lt.save
end

["transporte"].each do |nombre|
	lt = LocationType.new :name => nombre
	lt.dinamic = true
	lt.save
end

# We create some devices
d1 = Device.new :name => "XuanJuan", :description => "Abierto de 9hs a 21hs"
location1 = Location.new
location1.location_category = LocationCategory.find_by_name "comercio"
location1.location_type = LocationType.first
location1.device = d1
location1.save

d2 = Device.new :name => "Taxi_157", :description => "taxi con id 157"
location2 = Location.new
location2.location_category = LocationCategory.find_by_name "taxi"
location2.location_type = LocationType.last
location2.device = d2
location2.save

d3 = Device.new :name => "Taxi_189", :description => "taxi con id 189"
location3 = Location.new
location3.location_category = LocationCategory.find_by_name "taxi"
location3.location_type = LocationType.last
location3.device = d3
location3.save

# Set location_point on each device
lp1 = LocationPoint.new :latitude => 25.157, :longitude => 30.587
lp1.location = location1
lp1.save	
location1.current_location_point = lp1
location1.save

lp2 = LocationPoint.new :latitude => 25.158, :longitude => 30.588
lp2.location = location2
lp2.save	
location2.current_location_point = lp2
location2.save

lp3 = LocationPoint.new :latitude => 25.258, :longitude => 30.256
lp3.location = location2
lp3.save	
location3.current_location_point = lp3
location3.save