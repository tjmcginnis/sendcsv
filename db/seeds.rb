unless Rails.env.development?
  puts "Skipping seeds in non-development environment"
else
  def create_user(email_address)
    User.find_or_create_by!(email_address: email_address) do |user|
      user.password = "s3cr3t!"
    end
  end

  def create_table(name, user)
    Table.find_or_create_by!(name: name, user: user)
  end

  def create_ingestion(table)
    Ingestion.create!(table: table)
  end

  def create_rows(ingestion)
    csv = "Name,Age,City,Description\n"
    10.times do
      csv += "#{Faker::Name.name},#{Faker::Number.number(digits: 2)}," \
             "#{Faker::Address.city},#{Faker::Lorem.sentence}\n"
    end

    ingestion.process csv
  end

  def seed_user(email_address, with_rows: false)
    user = create_user email_address
    table = create_table "(default)", user

    if with_rows
      ingestion = create_ingestion table
      create_rows ingestion
    end
  end

  seed_user "me@example.com", with_rows: true
  seed_user "you@example.com"
  seed_user "manyrows@example.com"
end
