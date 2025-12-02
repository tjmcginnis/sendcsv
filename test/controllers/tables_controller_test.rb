require "test_helper"

class TablesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as users(:one)
  end

  test "index" do
    # TODO: Use helper once model created
    get "/"
    assert_response :success
  end
end
