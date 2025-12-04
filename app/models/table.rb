class Table < ApplicationRecord
  include PublicIdGenerator
  belongs_to :user

  def to_param
    public_id
  end
end
