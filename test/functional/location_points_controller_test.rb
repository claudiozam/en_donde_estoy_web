require 'test_helper'

class LocationPointsControllerTest < ActionController::TestCase
  setup do
    @location_point = location_points(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:location_points)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create location_point" do
    assert_difference('LocationPoint.count') do
      post :create, location_point: { device_id: @location_point.device_id, latitude: @location_point.latitude, longitude: @location_point.longitude }
    end

    assert_redirected_to location_point_path(assigns(:location_point))
  end

  test "should show location_point" do
    get :show, id: @location_point
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @location_point
    assert_response :success
  end

  test "should update location_point" do
    put :update, id: @location_point, location_point: { device_id: @location_point.device_id, latitude: @location_point.latitude, longitude: @location_point.longitude }
    assert_redirected_to location_point_path(assigns(:location_point))
  end

  test "should destroy location_point" do
    assert_difference('LocationPoint.count', -1) do
      delete :destroy, id: @location_point
    end

    assert_redirected_to location_points_path
  end
end
