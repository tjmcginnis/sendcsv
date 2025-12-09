require "test_helper"

class IngestionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @table = tables(:one)
    @valid_csv = "Name,Age,City\nAlice,30,Boston\nBob,25,Denver"
    @csv_headers = { "Content-Type" => "text/csv" }
  end

  test "create" do
    assert_difference "Ingestion.count", 1 do
      post in_path(@table.public_id), params: @valid_csv, headers: @csv_headers
    end

    assert_response :created

    json_response = JSON.parse(response.body)
    assert_equal "Ingestion created successfully", json_response["message"]
    assert json_response["ingestion_id"].present?
  end

  test "create with an unsupported content type" do
    post in_path(@table.public_id),
      params: @valid_csv,
      headers: { "Content-Type" => "application/json" }

    assert_response :unsupported_media_type

    json_response = JSON.parse(response.body)
    assert_equal "Invalid content type", json_response["error"]
  end

  test "create with a missing content type" do
    post in_path(@table.public_id), params: @valid_csv
    assert_response :unsupported_media_type
  end

  test "create with a non-existent table" do
    assert_no_difference "Ingestion.count" do
      post in_path("nonexistent123"), params: @valid_csv, headers: @csv_headers
    end
    assert_response :unprocessable_entity
  end

  test "create denied with a malformed csv" do
    malformed_csv = "Name,Age\n\"unclosed quote"
    post in_path(@table.public_id), params: malformed_csv, headers: @csv_headers
    assert_response :unprocessable_entity
  end

  test "create denied with an invalid csv header" do
    mismatched_csv = "Different,Headers,Here\nval1,val2,val3"
    post in_path(@table.public_id), params: mismatched_csv, headers: @csv_headers
    assert_response :unprocessable_entity
  end

  test "create denied when daily row limit is exceeded" do
    Table.any_instance.stubs(:daily_row_count).returns(10_000)
    csv_data = "Name,Age,City\nTony,99,Philadelphia"

    post in_path(@table.public_id), params: csv_data, headers: @csv_headers
    assert_response :unprocessable_entity
  end
end
