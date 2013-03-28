class Api::DeviceController < ApplicationController

	##
  # Obtiene dispositivos cercanos. El mismo permite realizar filtrado por categoria, y nombre del dispositivo.  #
  #
  # @resource api/device/create
  # @action POST
  #
  # @required [string] name Nombre del dispositivo.
  # @required [integer] category_id 
  # @required [integer] type_id 
  #
  # @response_field [string] message String con el resultado del metodo.
  # @response_field [integer] code Valor entero con el codigo con el que finaliza el metodo.
  #   <ul>
  #      <li><strong>000</strong> SUCCESS
  #      <li><strong>600</strong> El nombre ya existe
  #      <li><strong>603</strong> Parametros incorrectos.
  #      <li><strong>999</strong> ERROR
  #   </ul>
  #
  def create
    if params[:name].blank? or params[:category_id].blank? or params[:type_id].blank?
      render json: { :code => 603, :message => "Please, check data you are sending. There is data mising." }    
    else
      device = Device.new :name => params[:name]    
      if device.valid?
        Location = Location.new
        location.location_category = LocationCategory.find(params[:category_id])
        location.location_type = LocationType.find(params[:type_id])
        location.device = device
        location.save
      else
        render json: { :message => 'Device name has already been taken.', :code => 600 }
      end
    end  
  rescue Exception => e
    render json: { :message => 'There was an error while processing this request.', :code => 999 }
  end

  ##
  # Actualiza la posición actual de un dispositivo.
  # 
  # @resource api/:id/update_location
  # @action PUT
  #
  # @required [integer] latitude Latitud del dispositivo que solicita posiciones de dispositivos cercanas. Este valor es recibido por url
  # @required [integer] longitud Longitud del dispositivo que solicita posiciones de dispositivos cercanas. Este valor es recibido por url
  # @required [integer] id ID del dispositivo al que vamos a actualizar la posicion actual. Tener en cuenta que viene por url este parametro. 
  #
  # @response_field [string] message String con el resultado del metodo.
  # @response_field [integer] code Valor entero con el codigo con el que finaliza el metodo.
  #   <ul>
  #      <li><strong>000</strong> SUCCESS
  #      <li><strong>405</strong> No se encontro el dispositivo
  #      <li><strong>999</strong> ERROR
  #   </ul>
  #
  def update_location
    device = Device.find params[:device_id]
    location = device.location
    
    location_point = LocationPoint.new :latitude => params[:latitude], :longitude => params[:longitude]
    location.current_location_point = location_point
    location.save

    render json: { :message => 'Updated sucessfully.', :code => 000 }
  rescue ActiveRecord::RecordNotFound
    render json: { :message => 'Could not find device.', :code => 405 }
  rescue Exception => e
    render json: { :message => 'There was an error while trying to update this location.', :code => 999 }
  end  


end