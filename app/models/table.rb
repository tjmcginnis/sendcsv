class Table < ApplicationRecord
  include PublicIdGenerator
  belongs_to :user
end
