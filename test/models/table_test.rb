require "test_helper"

class TableTest < ActiveSupport::TestCase
  setup do
    @table = tables(:one)
  end

  test "updating header accepts additional columns" do
    @table.update_header!([ "Name", "Age", "City", "Country" ])
    assert_equal [ "Name", "Age", "City", "Country" ], @table.reload.header
  end

  test "updating header raises with mismatched columns" do
    assert_raises Table::HeaderMismatchError do
      @table.update_header!([ "Different", "Headers", "Here" ])
    end
    assert_equal [ "Name", "Age", "City" ], @table.reload.header
  end

  test "updating header raises with misordered columns" do
    assert_raises Table::HeaderMismatchError do
      @table.update_header!([ "Age", "Name", "City" ])
    end
    assert_equal [ "Name", "Age", "City" ], @table.reload.header
  end

  test "updating header raises with fewer columns" do
    assert_raises Table::HeaderMismatchError do
      @table.update_header!([ "Name", "Age" ])
    end
    assert_equal [ "Name", "Age", "City" ], @table.reload.header
  end

  test "updating header raises with partial match" do
    assert_raises Table::HeaderMismatchError do
      @table.update_header!([ "Name", "Age", "State" ])
    end
    assert_equal [ "Name", "Age", "City" ], @table.reload.header
 end

  test "updating empty header" do
    empty_table = tables(:empty)
    empty_table.update_header!([ "Any", "Headers", "Work" ])
    assert_equal [ "Any", "Headers", "Work" ], empty_table.reload.header
  end

  test "daily row count is 0 when no rows" do
    new_table = Table.create!(name: "Test", user: users(:one), header: [])
    assert_equal 0, new_table.daily_row_count
  end

  test "daily row count reflects rows created today" do
    new_table = Table.create!(name: "Test", user: users(:one), header: [])
    ingestion = new_table.ingestions.create(status: :completed)

    3.times do |i|
      new_table.rows.create!(
        ingestion: ingestion,
        contents: [ "Test", "#{i}", "City" ]
      )
    end

    new_table.reload
    assert_equal 3, new_table.daily_row_count
  end
end
