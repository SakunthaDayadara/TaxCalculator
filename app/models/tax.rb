class Tax < ApplicationRecord
  validates :grossincome, numericality: { greater_than_or_equal_to: 0, message: "must be a positive number" }

end
