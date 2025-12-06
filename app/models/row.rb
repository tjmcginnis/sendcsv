class Row < ApplicationRecord
  include PublicIdGenerator
  belongs_to :table
  belongs_to :ingestion

  def to_param
    public_id
  end
end
