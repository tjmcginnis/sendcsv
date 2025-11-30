require "test_helper"

class PublicIdGeneratorTest < ActiveSupport::TestCase
  # Create a temporary model to test the concern
  class TestRecord < ApplicationRecord
    self.table_name = "test_records"
    include PublicIdGenerator
  end

  setup do
    ActiveRecord::Base.connection.create_table :test_records, force: true do |t|
      t.string :public_id
      t.timestamps
    end
    ActiveRecord::Base.connection.add_index :test_records, :public_id, unique: true
  end

  teardown do
    ActiveRecord::Base.connection.drop_table :test_records, if_exists: true
  end

  test "public_id has correct length of 12 characters" do
    record = TestRecord.create!
    assert_equal PublicIdGenerator::PUBLIC_ID_LENGTH, record.public_id.length
  end

  test "public_id only contains valid alphabet characters" do
    record = TestRecord.create!
    assert_equal(
      0,
      record.public_id.count("^#{PublicIdGenerator::PUBLIC_ID_ALPHABET}"),
      "#{record.public_id} contains invalid characters"
    )
  end

  test "public_id matches PUBLIC_ID_REGEX" do
    record = TestRecord.create!
    assert_match PublicIdGenerator::PUBLIC_ID_REGEX, record.public_id
  end

  test "public_id is nil before save" do
    record = TestRecord.new
    assert_nil record.public_id
  end

  test "public_id is generated on create" do
    record = TestRecord.create!
    assert_not_nil record.public_id
    assert record.public_id.present?
  end

  test "set_public_id is called automatically via before_create callback" do
    record = TestRecord.new
    assert_nil record.public_id

    record.save!
    assert_not_nil record.public_id
  end

  test "multiple records get unique public_ids" do
    record1 = TestRecord.create!
    record2 = TestRecord.create!
    record3 = TestRecord.create!

    assert_not_equal record1.public_id, record2.public_id
    assert_not_equal record2.public_id, record3.public_id
    assert_not_equal record1.public_id, record3.public_id
  end

  test "existing public_id is not overwritten on save" do
    record = TestRecord.create!
    original_public_id = record.public_id

    record.updated_at = Time.current
    record.save!

    assert_equal original_public_id, record.public_id
  end

  test "existing public_id is preserved when object is reloaded" do
    record = TestRecord.create!
    original_public_id = record.public_id

    reloaded_record = TestRecord.find(record.id)
    assert_equal original_public_id, reloaded_record.public_id
  end

  test "set_public_id does not change existing public_id" do
    record = TestRecord.create!
    original_public_id = record.public_id

    record.set_public_id

    assert_equal original_public_id, record.public_id
  end

  test "manually set public_id is preserved on create" do
    custom_id = "custom123456"
    record = TestRecord.new(public_id: custom_id)
    record.save!

    assert_equal custom_id, record.public_id
  end

  test "generates a new public_id when collision occurs" do
    existing_record = TestRecord.create!
    existing_id = existing_record.public_id

    # Create a record class that returns the existing ID first, then a unique one
    call_count = 0
    collision_record = TestRecord.new
    collision_record.define_singleton_method(:generate_public_id) do
      call_count += 1
      call_count == 1 ? existing_id : "unique123456"
    end

    collision_record.set_public_id

    assert_equal(
      2,
      call_count,
      "Expected generate_public_id to be called twice due to collision"
    )
    assert_equal "unique123456", collision_record.public_id
  end

  test "raises error after MAX_RETRY failed attempts" do
    existing_record = TestRecord.create!
    existing_id = existing_record.public_id

    # Create a record that always returns the existing ID
    new_record = TestRecord.new
    new_record.define_singleton_method(:generate_public_id) { existing_id }

    error = assert_raises(RuntimeError) do
      new_record.set_public_id
    end
    assert_equal(
      "Failed to generate a unique public id after #{PublicIdGenerator::MAX_RETRY} attempts",
      error.message
    )
  end

  test "generate_nanoid accepts custom alphabet and size" do
    custom_alphabet = "ABC123"
    custom_size = 8
    nanoid = TestRecord.generate_nanoid(alphabet: custom_alphabet, size: custom_size)

    assert_equal custom_size, nanoid.length
    assert_equal 0, nanoid.count("^#{custom_alphabet}")
  end
end
