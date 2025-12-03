require "application_system_test_case"

class ManagingTablesTest < ApplicationSystemTestCase
  setup do
    sign_in_as users(:one).email_address
    assert_selector "h1", text: "Tables"
  end

  test "managing tables" do
    assert_selector "p", text: tables(:one).name
    assert_selector "p", text: tables(:one).public_id
  end
end
