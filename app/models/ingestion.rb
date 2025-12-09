require "csv"

class Ingestion < ApplicationRecord
  include PublicIdGenerator
  belongs_to :table
  has_many :rows

  enum :status, [ :pending, :processing, :completed, :failed ]

  class DailyLimitExceededError < StandardError; end

  def process(raw_csv)
    transaction do
      csv_data = parse_csv(raw_csv)

      table.update_header!(csv_data.headers.to_a)

      update(status: :processing)
      new_rows = csv_data.map do |csv_row|
        {
          table_id: table.id,
          ingestion_id: id,
          contents: csv_row.fields,
          public_id: Row.generate_nanoid
        }
      end

      validate_daily_row_limit!(new_rows.size)

      Row.insert_all(new_rows)
      table.increment_daily_row_count(new_rows.size)

      update(status: :completed)
    end
  rescue CSV::MalformedCSVError
    fail_with("Malformed CSV")
  rescue Table::HeaderMismatchError
    fail_with("CSV header is append only")
  rescue DailyLimitExceededError => e
    fail_with(e.message)
  rescue StandardError => e
    fail_with(e.message)
  end

  private
    def parse_csv(raw_csv)
      CSV.parse(raw_csv, headers: true)
    end

    def validate_daily_row_limit!(new_row_count)
      current_count = table.daily_row_count

      if current_count + new_row_count > Table::DAILY_ROW_LIMIT
        raise DailyLimitExceededError, "Daily limit exceeded"
      end
    end

    def fail_with(message)
      update(status: :failed, error_message: message)
      raise
    end
end
