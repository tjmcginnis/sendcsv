class Ingestion < ApplicationRecord
  include PublicIdGenerator
  belongs_to :table
  has_many :rows

  enum :status, [ :pending, :processing, :completed, :failed ]
end
