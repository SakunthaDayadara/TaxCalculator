




class Tax < ApplicationRecord
  validates :grossincome, numericality: { greater_than: 0, message: "must be a positive number" }

end
