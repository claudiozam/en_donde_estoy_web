class Api::LocationPointController < ApplicationController
 
  # Method GET 
  # Obtiene dispositivos cercanos. El mismo permite realizar filtrado por categoria, y nombre del dispositivo.
  #
  # [url] api/location_points/near_location_points/:latitude/:longitude
  # [Parametros]
  # [latitude] Latitude del dispositivo que solicita posiciones de dispositivos cercanas. Este valor es recibido por url
  # [longitud] Longitud del dispositivo que solicita posiciones de dispositivos cercanas. Este valor es recibido por url
  # [device_name] Nombre del dispositivo buscado. (En caso de que no se quiera filtrar por este campo se lo envia como vacio.)
  # [category_name] Nombre de la categoria a la que pertenece el dispositivo buscado. (En caso de que no se quiera filtrar por este campo se lo envia como vacio.)
  #
  # [Returns]
  # [message] String con el resultado del metodo.
  # [list] Array con los location_points encontrados. Dentro del array habran arrays con información de cada location encontrado.
  #        Cada array de location tendra:
  #             *latitude: Valor de la latitud. Actualmente es un integer sin formato
  #             *longitude: Valor de la longitud. Actualmente es un integer sin formato
  #             *updated_at: Fecha de creacion del mismo
  #             *category: Nombre de la categoria a la que pertenece. 
  #             *device: Nombre el dispositivo.
  # [code] Valor entero con el codigo con el que finaliza el metodo.
  #        Opciones
  #             *000 SUCCESS
  #             *600 No se encontraron location points
  #             *601 No se pasaron longitud o latitud en la url
  #             *999 ERROR
  #
  # Ejemplo de listado:
  #  => [[{:latitude=>37.7941, :longitude=>-56.2113, :updated_at=>"2013-03-24 1805", :category=>"Comercio", :device=>"SebaHouse"}], [{:latitude=>23.5543, :longitude=>-56.2113, :updated_at=>"2013-03-24 1805", :category=>"Comercio", :device=>"SebaHouse"}]] 
  #
  #@returns[:message]
  #@returns[:list]
  #@returns[:code]
  def find_near_location_points
    if params[:latitude].blank? or params[:longitude].blank?
      render json: {:code => 601, :message => "Please, make sure to send both latitude or longitude. It seams that at least one of them is blank"} }    
    end

    location_points = Location.near_location_points(params[:latitude],params[:longitude]).
                                with_device_name(params[:device_name]).
                                with_category(params[:category_name]).
                                limit(20).
                                each.collect &:current_location_point
    
    if @location_points.count == 0
      render json: {:code => 600, :message => "There were not near location with those "} }    
    else
      result = []
      location_points.each do |location_point|
        lp = Location.find location_point.id
        current_location_point = lp.current_location_point
        result << [ :latitude => current_location_point.latitude,
                    :longitude => current_location_point.longitude,
                    :updated_at => I18n.l( current_location_point.created_at,:format => :long), 
                    :category => l.location_category.name,
                    :device => l.device.name ]
      end
      render json: {:code => 000, :list => result }    
    end  
  rescue Exception => e
    render json: { :message => 'There was an error while processing this request.', :code => 999 }
  end

  # Method PUT 
  # Actualiza la posición actual de un dispositivo.
  #
  # [url] api/location_points/near_location_points
  # [Parametros] 
  # [latitude] Latitude del dispositivo que solicita posiciones de dispositivos cercanas.
  # [longitud] Longitud del dispositivo que solicita posiciones de dispositivos cercanas.
  # [device_id] ID del dispositivo al que vamos a actualizar la posicion actual. 
  #
  # [Returns]
  # [message] String con el resultado del metodo.
  # [code] Valor entero con el codigo con el que finaliza el metodo.
  #        Opciones
  #             *000 SUCCESS
  #             *405 No se encontro el dispositivo.
  #             *999 ERROR
  # @params[device_id]
  # @params[latitude]
  # @params[longitude]
  # @returns[:message]
  # @returns[:code]
  def update_location
    device = Device.find params[:device_id]
    location = device.location
    
    location_point = LocationPoint.new :latitude => params[:latitude], :longitude => params[:longitude]
    location_point.device = device
    location_point.save
    location.current_location_point = location_point
    location.save

    render json: { :message => 'Updated sucessfully.', :code => 000 }
  
  rescue ActiveRecord::RecordNotFound
    render json: { :message => 'Could not find device.', :code => 405 }
  rescue Exception => e
    render json: { :message => 'There was an error while trying to update this location.', :code => 999 }
  end  
  end




end