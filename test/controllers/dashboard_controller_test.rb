require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "GET dashboard#index empty" do
    get dashboard_index_url
    assert_response :success
  end

  test "GET dashboard#index with logs" do
    10.times { Log.create!(url: "test", requested_at: Time.now.utc) }

    get dashboard_index_url
    assert_response :success
  end
end
