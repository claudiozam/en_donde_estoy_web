class Api::LocationsController < ApplicationController
  ##
  # Obtiene dispositivos cercanos. El mismo permite realizar filtrado por categoria del dispositivo.  #
  #
  # @resource /api/locations/find_near_locations/:latitude/:longitude/:category_name
  # @action GET
  #
  # @required [integer] latitude Latitud del dispositivo que solicita posiciones de dispositivos cercanas. Este valor es recibido por url
  # @required [integer] longitud Longitud del dispositivo que solicita posiciones de dispositivos cercanas. Este valor es recibido por url 
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
  #      <li><strong>device_description</strong> Texto con la descripcion del dispositivo. 
  #   </ul>
  # @response_field [string] code numero que representa el resultado del request. 
  #   <ul>
  #      <li><strong>000</strong> SUCCESS </li>
  #      <li><strong>600</strong> No se encontraron location points. </li>
  #      <li><strong>601</strong> No se pasaron longitud o latitud en la url. </li>
  #      <li><strong>999</strong> ERROR </li>
  #   </ul>
  # @example_request 
  #   $.ajax({ type: 'GET', url: "/api/locations/find_near_locations/30.5/21.5/all" })
  # @example_response 
  #   {"code":"000","list":[{"latitude":25.158,"longitude":30.588,"updated_at":"2013-04-14 19:18","category":"taxi","device":"Taxi_157","device_description":"taxi con id 157"},{"latitude":25.5,"longitude":35.0,"updated_at":"2013-04-14 20:08","category":"personal","device":"XuanJuan","device_description":"Abierto de 9hs a 21hs"}]}
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
          result << { :latitude => current_location_point.latitude,
                      :longitude => current_location_point.longitude,
                      :updated_at => I18n.l( current_location_point.created_at,:format => :long), 
                      :category => location.location_category.name,
                      :device => location.device.name,
                      :device_description => location.device.description }
        end
        response = { :code => "000", :list => result }    
      end  
    end
    render json: response
  rescue Exception => e
    render json: { :message => "There was an error while processing this request. #{e}", :code => "999" }
  end

  ##
  # Obtiene el ultimo location_point del dispositivo que se desea buscar. 
  #
  # @resource /api/locations/:device_name/get_location
  # @action GET
  #
  # @required [string] device_name Nombre del dispositivo buscado.
  # @response_field [Hash] location_point Un hash con los datos del ultimo location_point del dispositivo.
  #   <ul>
  #      <li><strong>latitude</strong> Valor de la longitud.
  #      <li><strong>longitude</strong> Valor de la latitude.
  #      <li><strong>created_at</strong> Fecha en que fue actualizada la location. El formato del mismo es "%Y-%m-%d %H:%M" (Eg: 2013-03-24 18:06:29)
  #   </ul>
  # @response_field [string] message String con el resultado del metodo.
  # @response_field [string] code numero que representa el resultado del request. 
  #   <ul>
  #      <li><strong>000</strong> SUCCESS </li>
  #      <li><strong>405</strong> No se encontro el device solicitado.</li>
  #      <li><strong>601</strong> No se paso nombre del device o el mismo es "blanco".</li>
  #      <li><strong>999</strong> ERROR</li>
  #   </ul>
  # @example_request 
  #   $.ajax({ type: 'GET', url: "/api/locations/XuanJuan/get_location" })
  # @example_response 
  #   "{"location_point":[{"latitude":25.5,"longitude":35.0,"created_at":"2013-04-14 20:08"}],"code":"000"}"
  #
  def get_location
    if params[:device_name].blank?
      response = { :message => "Please, make sure to send the device_name to search.", :code => "601" }
    else
      location = Location.with_device_name(params[:device_name])
      if location.empty?
        response = { :message => 'Could not find device.', :code => "405" } 
      else
        location_point = location.first.current_location_point
        result = []
        result << { :latitude => location_point.latitude,
                    :longitude => location_point.longitude,
                    :created_at => I18n.l( location_point.created_at,:format => :long) }
        response = { :location_point => result, :code => "000" }
      end
    end
    render json: response
  rescue Exception => e
    render json: { :message => "There was an error while processing this request. #{e}", :code => "999" }
  end

  ##
  # Obtiene toda las categorias posibles para locations.
  #
  # @resource /api/locations/get_all_categories
  # @action GET
  #
  # @response_field [array] categories Lista de hashes con los datos de cada categoria.
  #   <ul>
  #      <li><strong>id</strong> Id de la categoria (valor integer).
  #      <li><strong>nombre</strong> Nombre de la categoria.
  #      <li><strong>descripcion</strong> Descripcion de la categoria.
  #   </ul>
  # @response_field [string] code numero que representa el resultado del request. 
  #   <ul>
  #      <li><strong>000</strong> SUCCESS </li>
  #      <li><strong>999</strong> ERROR</li>
  #   </ul>
  # @example_request 
  #   $.ajax({ type: 'GET', url: "/api/locations/get_all_categories" })
  # @example_response 
  #   "{"categories":[{"id":1,"name":"personal","description":null},{"id":2,"name":"comercio","description":null},{"id":3,"name":"instituto","description":null},{"id":4,"name":"taxi","description":null},{"id":5,"name":"colectivo","description":null}],"code":"000"}"
  #
  def get_all_categories
    location_categories = LocationCategory.all
    result = []
    location_categories.each do |category|
    result << { :id => category.id,
                :name => category.name,
                :description => category.description }
    end
    response = { :categories => result, :code => "000" }
    render json: response
  rescue Exception => e
    render json: { :message => "There was an error while processing this request. #{e}", :code => "999" }
  end

  ##
  # Obtiene todos los tipos posibles para locations.
  #
  # @resource /api/locations/get_all_types
  # @action GET
  #
  # @response_field [array] types Lista de hashes con los datos de cada categoria.
  #   <ul>
  #      <li><strong>id</strong> Id del tipo de location (valor integer).
  #      <li><strong>nombre</strong> Nombre del tipo de location.
  #      <li><strong>dinamic</strong> Valor entero que representa si la location es dinamica. (1 = verdadero, 0 = falso)
  #      <li><strong>descripcion</strong> Descripcion del tipo de location.
  #   </ul>
  # @response_field [string] code numero que representa el resultado del request. 
  #   <ul>
  #      <li><strong>000</strong> SUCCESS </li>
  #      <li><strong>999</strong> ERROR</li>
  #   </ul>
  # @example_request 
  #   $.ajax({ type: 'GET', url: "/api/locations/get_all_types" })
  # @example_response 
  #   "{"types":[{"id":1,"name":"establecimiento","dinamic":false,"description":null},{"id":2,"name":"movil","dinamic":false,"description":null},{"id":3,"name":"transporte","dinamic":true,"description":null}],"code":"000"}"
  #
  def get_all_types
    location_types = LocationType.all
    result = []
    location_types.each do |type|
    result << { :id => type.id,
                :name => type.name,
                :dinamic => type.dinamic,
                :description => type.description }
    end
    response = { :types => result, :code => "000" }
    render json: response
  rescue Exception => e
    render json: { :message => "There was an error while processing this request. #{e}", :code => "999" }
  end
end