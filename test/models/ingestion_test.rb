require "test_helper"

class IngestionTest < ActiveSupport::TestCase
  setup do
    @table = tables(:one)
    @ingestion = @table.ingestions.create(status: :pending)
    @valid_csv = "Name,Age,City\nAlice,30,Boston\nBob,25,Denver"
  end

  test "processing appends rows from csv" do
    assert_difference "Row.count", 2 do
      @ingestion.process(@valid_csv)
    end

    row = @ingestion.rows.first
    assert_equal [ "Alice", "30", "Boston" ], row.contents
    assert @ingestion.reload.completed?
  end

  test "processing updates header when csv has new columns" do
    csv_with_new_columns = "Name,Age,City,Country\nAlice,30,Boston,USA"
    @ingestion.process(csv_with_new_columns)
    assert_equal [ "Name", "Age", "City", "Country" ], @table.reload.header
  end

  test "processing error sets status to failed" do
    malformed_csv = "Name,Age\n\"unclosed"

    assert_no_difference "Row.count" do
      assert_raises { @ingestion.process(malformed_csv) }
    end

    assert @ingestion.reload.failed?
    assert @ingestion.reload.error_message.present?
  end

  test "processing raises with csv header mismatch" do
    mismatched_csv = "Different,Headers,Here\nval1,val2,val3"

    assert_no_difference "Row.count" do
      assert_raises Table::HeaderMismatchError do
        @ingestion.process(mismatched_csv)
      end
    end

    assert_equal "CSV header is append only", @ingestion.error_message
  end

  test "processing sets table header" do
    empty_table = tables(:empty)
    ingestion = empty_table.ingestions.create(status: :pending)
    csv = "Name,Age\nAlice,30"

    ingestion.process(csv)

    assert ingestion.completed?
    assert_equal [ "Name", "Age" ], empty_table.reload.header
  end

  test "processing fails when daily row limit exceeded" do
    @table.stubs(:daily_row_count).returns(10_000)
    csv = "Name,Age,City\nPenny,30,Santa Cruz"

    assert_raises(StandardError) do
      @ingestion.process(csv)
    end

    assert @ingestion.reload.failed?
    assert_equal "Daily limit exceeded", @ingestion.error_message
  end
end
