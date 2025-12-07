class Table < ApplicationRecord
  include PublicIdGenerator
  belongs_to :user
  has_many :rows, dependent: :destroy
  has_many :ingestions, dependent: :destroy

  scope :with_rows, -> { includes(:rows) }

  class HeaderMismatchError < StandardError; end

  def to_param
    public_id
  end

  def update_header!(new_header)
    return if header == new_header
    validate_header!(new_header)
    update!(header: new_header)
  end

  private
    def validate_header!(new_header)
      raise HeaderMismatchError unless new_header.take(header.size) == header
    end
end
