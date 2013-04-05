class Api::LocationController < ApplicationController
  ##
  # Obtiene dispositivos cercanos. El mismo permite realizar filtrado por categoria, y nombre del dispositivo.  #
  #
  # @resource api/location/find_near_location/:latitude/:longitude
  # @action POST
  #
  # @required [integer] latitude Latitud del dispositivo que solicita posiciones de dispositivos cercanas. Este valor es recibido por url
  # @required [integer] longitud Longitud del dispositivo que solicita posiciones de dispositivos cercanas. Este valor es recibido por url
  # @optional [string] device_name Nombre del dispositivo buscado. (En caso de que no se quiera filtrar por este campo se lo envia como vacio.)
  # @optional [string] category_name Nombre de la categoria a la que pertenece el dispositivo buscado. (En caso de que no se quiera filtrar por este campo se lo envia como vacio.)
  #
  # @response_field [string] message String con el resultado del metodo.
  # @response_field [Array] list Array con los location_points encontrados. Dentro del array habran arrays con información de cada location encontrado.
  #   <ul>
  #      <li><strong>latitude</strong> Valor de la latitud. Actualmente es un integer sin formato
  #      <li><strong>longitude</strong> Valor de la longitud. Actualmente es un integer sin formato
  #      <li><strong>updated_at</strong> Fecha de creacion del mismo. El formato del mismo es "%Y-%m-%d %H:%M" (Eg: 2013-03-24 18:06:29)
  #      <li><strong>category</strong> Nombre de la categoria a la que pertenece. 
  #      <li><strong>device</strong> Nombre el dispositivo.
  #   </ul>
  # @response_field [integer] code Valor entero con el codigo con el que finaliza el metodo.
  #   <ul>
  #      <li><strong>000</strong> SUCCESS
  #      <li><strong>600</strong> No se encontraron location points
  #      <li><strong>601</strong> No se pasaron longitud o latitud en la url
  #      <li><strong>999</strong> ERROR
  #   </ul>
  #
  def find_near_location_points
    if params[:latitude].blank? or params[:longitude].blank?
      render json: { :code => 601, :message => "Please, make sure to send both latitude or longitude. It seams that at least one of them is blank" }    
    end

    locations = Location.near_location_points(params[:latitude],params[:longitude]).
                                with_device_name(params[:device_name]).
                                with_category(params[:category_name]).
                                limit(20).
                                each.collect &:location_id
    
    if @location_points.count == 0
      render json: { :code => 600, :message => "There were not near location with those " } 
    else
      result = []
      locations.each do |location_id|
        location = Location.find location_id
        current_location_point = location.current_location_point
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

end