require "test_helper"

class TablesControllerTest < ActionDispatch::IntegrationTest
  test "index" do
    # TODO: Use helper once model created
    get "/"
    assert_response :success
  end
end
