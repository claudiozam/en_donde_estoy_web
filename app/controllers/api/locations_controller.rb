class Api::LocationsController < ApplicationController
  ##
  # Obtiene dispositivos cercanos. El mismo permite realizar filtrado por categoria, y nombre del dispositivo.  #
  #
  # @resource /locations/find_near_locations/:latitude/:longitude/:category_name
  # @action GET
  #
  # @required [integer] latitude Latitud del dispositivo que solicita posiciones de dispositivos cercanas. Este valor es recibido por url (Acordarse que en caso de que tenga coma, tenemos que scapearlas, por ejemplo: 22.5 = 22%2E5)
  # @required [integer] longitud Longitud del dispositivo que solicita posiciones de dispositivos cercanas. Este valor es recibido por url (Acordarse que en caso de que tenga coma, tenemos que scapearlas, por ejemplo: 22.5 = 22%2E5)
  # @required [string] category_name Nombre de la categoria a la que pertenece el dispositivo buscado. (En caso de que no se quiera filtrar por este campo se lo envia como "all"). Este valor es recibido por url.
  #
  # @response_field [string] message String con el resultado del metodo.
  # @response_field [array] list Array con los location_points encontrados. Dentro del array habran arrays con información de cada location encontrado.
  #   <ul>
  #      <li><strong>latitude</strong> Valor de la latitud. Actualmente es un integer sin formato
  #      <li><strong>longitude</strong> Valor de la longitud. Actualmente es un integer sin formato
  #      <li><strong>updated_at</strong> Fecha de creacion del mismo. El formato del mismo es "%Y-%m-%d %H:%M" (Eg: 2013-03-24 18:06:29)
  #      <li><strong>category</strong> Nombre de la categoria a la que pertenece. 
  #      <li><strong>device</strong> Nombre el dispositivo.
  #   </ul>
  # @response_field [string] code numero que representa el resultado del request. 
  #   <ul>
  #      <li><strong>000</strong> SUCCESS </li>
  #      <li><strong>600</strong> No se encontraron location points. </li>
  #      <li><strong>601</strong> No se pasaron longitud o latitud en la url. </li>
  #      <li><strong>999</strong> ERROR </li>
  #   </ul>
  #
  def find_near_locations
    if params[:latitude].blank? or params[:longitude].blank?
      response = { :code => "601", :message => "Please, make sure to send both latitude or longitude. It seams that at least one of them is blank" }    
    else
      locations_ids = Location.near_location_points(params[:latitude],params[:longitude]).
                            with_category(params[:category_name]).
                            limit(20).
                            each.collect &:location_id
      if locations_ids.count == 0
        response = { :code => "600", :message => "There were no near location with those" } 
      else
        result = []
        locations_ids.each do |ids|
          location = Location.find ids
          current_location_point = location.current_location_point
          result << [ :latitude => current_location_point.latitude,
                      :longitude => current_location_point.longitude,
                      :updated_at => I18n.l( current_location_point.created_at,:format => :long), 
                      :category => location.location_category.name,
                      :device => location.device.name ]
        end
        response = { :code => "000", :list => result }    
      end  
    end
    render json: response
  rescue Exception => e
    render json: { :message => "There was an error while processing this request. #{e}", :code => "999" }
  end

  ##
  # Obtiene el ultimo location_point del device que se desea buscar. 
  #
  # @resource /locations/:device_name/get_location
  # @action GET
  #
  # @required [string] device_name Nombre del dispositivo buscado.
  # @responsese_field [string] message String con el resultado del metodo.
  # @response_field [string] code numero que representa el resultado del request. 
  #   <ul>
  #      <li><strong>000</strong> SUCCESS </li>
  #      <li><strong>405</strong> No se encontro el device solicitado.</li>
  #      <li><strong>601</strong> No se paso nombre del device o el mismo es "blanco".</li>
  #      <li><strong>999</strong> ERROR</li>
  #   </ul>
  #
  def get_location
    if params[:device_name].blank?
      response = {:message => "Please, make sure to send the device_name to search.", :code => "601"}
    else
      location = Location.with_device_name params[:device_name]
      response = { :location => location, :code => "000" }
    end
    render json: response
  rescue ActiveRecord::RecordNotFound
    render json: { :message => 'Could not find device.', :code => "405" }  
  rescue Exception => e
    render json: { :message => "There was an error while processing this request. #{e}", :code => "999" }
  end

end