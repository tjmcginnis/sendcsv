require_relative "../config/environment"
require "faker"

USER = User.find_by(email_address: "manyrows@example.com")
ROW_COUNT = ARGV.first&.to_i || 10_000

Current.session = USER.sessions.first
table = USER.tables.first
table.header = [ "user_id", "event_type", "event_timestamp", "metadata" ]
table.save!
ingestion = table.ingestions.create!(status: :processing)

puts "Creating #{ROW_COUNT} rows for user #{USER.email_address} in #{table.name} table"

ROW_COUNT.times do |i|
  row = ingestion.rows.create!(
    table_id: table.id,
    contents: [
      Faker::Number.number(digits: 5),
      Faker::Lorem.word,
      Faker::Time.backward(days: 365, period: :all),
      {
        info: Faker::Lorem.sentence,
        value: Faker::Number.decimal(l_digits: 2, r_digits: 2)
      }.to_json
    ]
  )
  print "."
end
ingestion.update!(status: :completed)
