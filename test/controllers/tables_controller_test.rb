require "test_helper"

class TablesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as users(:one)
  end

  test "index" do
    get root_url
    assert_response :success
  end
end
