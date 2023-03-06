class Image < ApplicationRecord
  validates :url, uniqueness: true

  KNOWN_FORMATS = [
    'image/png',
    'image/bmp',
    'image/heic',
    'image/webp'
  ]

  def format_to_extension
    if KNOWN_FORMATS.include? self.format
      ".#{self.format.split('/').last}"
    elsif self.format == 'image/jpeg'
      '.jpg'
    elsif self.format == 'image/svg+xml'
      '.svg'
    else
      '.jpg'
    end
  end
end
