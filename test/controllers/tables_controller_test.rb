require "test_helper"

class TablesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as users(:one)
  end

  test "index" do
    get root_url
    assert_response :success
  end

  test "show" do
    get table_url(tables(:one))
    assert_response :success
  end

  test "ensure user can't view a table belonging to another user" do
    get table_url(tables(:two))
    assert_response :not_found
  end
end
