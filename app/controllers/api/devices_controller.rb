class Api::DevicesController < ApplicationController

	##
  # Obtiene dispositivos cercanos. El mismo permite realizar filtrado por categoria, y nombre del dispositivo.  #
  #
  # @resource /api/devices/create
  # @action POST
  #
  # @required [string] name Nombre del dispositivo.
  # @required [integer] category_id 
  # @required [integer] type_id 
  #
  # @response_field [string] message String con el resultado del metodo.
  # @response_field [integer] code Valor entero con el codigo con el que finaliza el metodo.
  #   <ul>
  #      <li><strong>000</strong> SUCCESS </li>
  #      <li><strong>600</strong> El nombre ya existe. </li>
  #      <li><strong>603</strong> Parametros incorrectos. </li>
  #      <li><strong>999</strong> ERROR </li>
  #   </ul>
  #
  def create
    if params[:name].blank? or params[:category_id].blank? or params[:type_id].blank?
      response = { :code => "603", :message => "Please, check data you are sending. There is data mising." }    
    else
      device = Device.new :name => params[:name]    
      if device.valid?
        location = Location.new
        location.location_category = LocationCategory.find(params[:category_id])
        location.location_type = LocationType.find(params[:type_id])
        location.device = device
        location.save
        response = { :message => 'Device was created successfuly.', :code => "600" }
      else
        response = { :message => 'Device name has already been taken.', :code => "600" }
      end
    end  
    render json: response
  rescue Exception => e
    render json: { :message => 'There was an error while processing this request.', :code => "999" }
  end

  ##
  # Actualiza la posición actual de un dispositivo.
  # 
  # @resource /api/devices/:id/update_location
  # @action PUT
  #
  # @required [integer] latitude Latitud del dispositivo que solicita posiciones de dispositivos cercanas. Este valor es recibido por url
  # @required [integer] longitud Longitud del dispositivo que solicita posiciones de dispositivos cercanas. Este valor es recibido por url
  # @required [integer] id ID del dispositivo al que vamos a actualizar la posicion actual. Tener en cuenta que viene por url este parametro. 
  #
  # @response_field [string] message String con el resultado del metodo.
  # @response_field [integer] code Valor entero con el codigo con el que finaliza el metodo.
  #   <ul>
  #      <li><strong>000</strong> SUCCESS </li>
  #      <li><strong>405</strong> No se encontro el dispositivo. </li>
  #      <li><strong>999</strong> ERROR </li>
  #   </ul>
  #
  def update_location
    device = Device.find params[:id]
    location = device.location
    
    location_point = LocationPoint.new :latitude => params[:latitude], :longitude => params[:longitude]
    location_point.location = location
    location_point.save
    location.current_location_point = location_point
    location.save

    render json: { :message => 'Updated sucessfully.', :code => "000" }
  rescue ActiveRecord::RecordNotFound
    render json: { :message => 'Could not find device.', :code => "405" }
  rescue Exception => e
    render json: { :message => 'There was an error while trying to update this location.', :code => "999" }
  end  


end