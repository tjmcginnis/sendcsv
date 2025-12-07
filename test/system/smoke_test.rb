require "application_system_test_case"

class SmokeTest < ApplicationSystemTestCase
  test "navigating tables" do
    sign_in_as users(:one).email_address
    assert_selector "h1", text: "Tables"

    assert_selector "p", text: tables(:one).name
    assert_selector "p", text: tables(:one).public_id

    click_on "View table"

    assert_selector "h1", text: tables(:one).name, wait: 5

    assert_field "Ingestion URL", with: in_url(tables(:one).public_id)
    assert_selector "button", text: "Copy to clipboard"

    assert_selector "th", text: "Name"
    assert_selector "th", text: "Age"
    assert_selector "th", text: "City"

    assert_selector "td", text: "Tyler"
    assert_selector "td", text: 37
    assert_selector "td", text: "Amherst"

    assert_selector "td", text: "Penny"
    assert_selector "td", text: 10
    assert_selector "td", text: "Santa Cruz"

    assert_selector "td", text: "Tony"
    assert_selector "td", text: 15
    assert_selector "td", text: "Philadelphia"
  end
end
