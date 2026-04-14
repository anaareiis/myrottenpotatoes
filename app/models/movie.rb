class Movie < ApplicationRecord
  validates :title, presence: true, uniqueness: { case_sensitive: false, message: "already exists in the database" }
  validates :rating, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 5, message: "must be an integer between 0 and 5" }
  validates :description, presence: true
  validates :release_date, presence: true
end