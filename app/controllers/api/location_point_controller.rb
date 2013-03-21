class Api::LocationPointController < ApplicationController
 
  #Method GET 
  #url : api/location_points/near_location_points/:latitude/:longitude/:name/:category
  #@params[device_id]
  #@returns[:message]
  #@returns[:code]
  def find_near_location_points
    #@location_points = LocationPoint.where(["created_at >= ? AND created_at <= ?", Time.now - 60, Time.now]).near([lat, lng], 5, :units => :km).limit(20)
    @location_points = LocationPoint.near([params[:latitude], params[:longitude]], 5, :units => :km).limit(20)

    logger.error "Todo mal!!!!!!!!!!!!"
    respond_to do |format|
      format.html # near_location_points.html.erb
      format.json { render json: @location_points }
    end
  end

  #Method PUT 
  #[url] api/location_points/near_location_points
  #@params[device_id]
  #@params[latitude]
  #@params[longitude]
  #@returns[:message]
  #@returns[:code]
  def update_location
    begin
      device = Device.find params[:device_id]
      location = device.location
      
      location_point = LocationPoint.new :latitude => params[:latitude], :longitude => params[:longitude]
      location_point.save
      location.current_location_point = location_point
      location.save

      render json: { :message => 'Updated sucessfully', :code => 000 }
    rescue Exception => e
      render json: { :message => 'There was an error while trying to update this location.', :code => 999 }
    end  
  end




end