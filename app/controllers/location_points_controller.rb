class LocationPointsController < ApplicationController
  


  def near_location_points
    lat = params[:lat]
    lng = params[:lng]
    #@location_points = LocationPoint.where(["created_at >= ? AND created_at <= ?", Time.now - 60, Time.now]).near([lat, lng], 5, :units => :km).limit(20)
    @location_points = LocationPoint.near([lat, lng], 5, :units => :km).limit(20)
    
    respond_to do |format|
      format.html # near_location_points.html.erb
      format.json { render json: @location_points }
    end
  end

  # GET /location_points
  # GET /location_points.json
  def index
    @location_points = LocationPoint.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @location_points }
    end
  end

  # GET /location_points/1
  # GET /location_points/1.json
  def show
    @location_point = LocationPoint.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @location_point }
    end
  end

  # GET /location_points/new
  # GET /location_points/new.json
  def new
    @location_point = LocationPoint.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @location_point }
    end
  end

  # GET /location_points/1/edit
  def edit
    @location_point = LocationPoint.find(params[:id])
  end

  # POST /location_points
  # POST /location_points.json
  def create
    @location_point = LocationPoint.new(params[:location_point])

    respond_to do |format|
      if @location_point.save
        format.html { redirect_to @location_point, notice: 'Location point was successfully created.' }
        format.json { render json: @location_point, status: :created, location: @location_point }
      else
        format.html { render action: "new" }
        format.json { render json: @location_point.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /location_points/1
  # PUT /location_points/1.json
  def update
    @location_point = LocationPoint.find(params[:id])

    respond_to do |format|
      if @location_point.update_attributes(params[:location_point])
        format.html { redirect_to @location_point, notice: 'Location point was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @location_point.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /location_points/1
  # DELETE /location_points/1.json
  def destroy
    @location_point = LocationPoint.find(params[:id])
    @location_point.destroy

    respond_to do |format|
      format.html { redirect_to location_points_url }
      format.json { head :no_content }
    end
  end
end
