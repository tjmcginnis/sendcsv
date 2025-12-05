class Row < ApplicationRecord
  include PublicIdGenerator
  belongs_to :table

  def to_param
    public_id
  end
end
