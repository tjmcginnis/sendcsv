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
end
