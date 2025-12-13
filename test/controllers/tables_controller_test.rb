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
    get table_url(tables(:empty))
    assert_response :not_found
  end

  test "show csv format" do
    get table_url(tables(:one), format: :csv)
    assert_response :success
    assert_equal "text/csv", response.headers["Content-Type"]
    assert_match /filename="izkpm55j334u\.csv"/, response.headers["Content-Disposition"]
  end

  test "ensure user can't export a table belonging to another user" do
    get table_url(tables(:empty), format: :csv)
    assert_response :not_found
  end
end
