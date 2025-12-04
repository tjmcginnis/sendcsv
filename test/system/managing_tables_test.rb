require "application_system_test_case"

class ManagingTablesTest < ApplicationSystemTestCase
  setup do
    sign_in_as users(:one).email_address
    assert_selector "h1", text: "Tables"
  end

  test "managing tables" do
    assert_selector "p", text: tables(:one).name
    assert_selector "p", text: tables(:one).public_id

    click_on "View table"

    assert_selector "h1", text: tables(:one).name
    assert_selector "th", text: "Name"
    assert_selector "th", text: "Age"
    assert_selector "th", text: "City"
  end
end
