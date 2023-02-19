class Image < ApplicationRecord
  def self.find_or_fetch(url)
    image = Image.find_by(url: url)

    if image.nil?
      tempfile = Down.download(url, max_size: 10 * 1024 * 1024)  # 10 MB
      image = Image.create!(url: url, format: tempfile.content_type, data: tempfile.read)
      tempfile.unlink
    end

    image
  end
end
