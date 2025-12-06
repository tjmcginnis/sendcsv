class Table < ApplicationRecord
  include PublicIdGenerator
  belongs_to :user
  has_many :rows, dependent: :destroy
  has_many :ingestions, dependent: :destroy

  scope :with_rows, -> { includes(:rows) }

  def to_param
    public_id
  end
end
