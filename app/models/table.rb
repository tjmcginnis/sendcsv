class Table < ApplicationRecord
  include PublicIdGenerator
  belongs_to :user
  has_many :rows, dependent: :destroy
  has_many :ingestions, dependent: :destroy

  scope :with_rows, -> { includes(:rows) }

  DAILY_ROW_COUNT_EXPIRY = 1.day + 1.hour
  DAILY_ROW_LIMIT = 10_000

  class HeaderMismatchError < StandardError; end

  def to_param
    public_id
  end

  def update_header!(new_header)
    return if header == new_header
    validate_header!(new_header)
    update!(header: new_header)
  end

  def daily_row_count
    Rails.cache.fetch(daily_row_count_cache_key, expires_in: DAILY_ROW_COUNT_EXPIRY) do
      rows.where("created_at >= ?", Time.current.beginning_of_day).count
    end
  end

  def increment_daily_row_count(count)
    current = Rails.cache.read(daily_row_count_cache_key) || 0
    Rails.cache.write(daily_row_count_cache_key, current + count, expires_in: DAILY_ROW_COUNT_EXPIRY)
  end

  private
    def validate_header!(new_header)
      raise HeaderMismatchError unless new_header.take(header.size) == header
    end

    def daily_row_count_cache_key
      "table:#{id}:rows:#{Date.current}"
    end
end
