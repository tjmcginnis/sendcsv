require "application_system_test_case"

class ManagingTablesTest < ApplicationSystemTestCase
  test "managing tables" do
    # TODO: Use helper once model created
    visit root_url
    assert_selector "h1", text: "Tables"
  end
end
