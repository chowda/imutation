class Image < ApplicationRecord
  validates :url, uniqueness: true
end
