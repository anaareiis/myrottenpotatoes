class Movie < ApplicationRecord
  validates :title, presence: true, uniqueness: { case_sensitive: false, message: "already exists in the database" }
  validates :rating, presence: true
  validates :description, presence: true
  validates :release_date, presence: true
end