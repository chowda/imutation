class ImageManager
  def self.call(url, changes={})
    if changes.any?
      variant_url = url + "?" + changes.map{|k,v| "#{k}=#{v}" }.join("&")
      variant_image = Image.find_by(url: variant_url)
      unless variant_image
        original_image = self.find_or_fetch_original!(url)
        variant_image = self.create_variant!(original_image, changes, variant_url)
      end
      variant_image
    else
      self.find_or_fetch_original!(url)
    end
  end

  private

  def self.find_or_fetch_original!(url)
    original_url = url.split("?").first
    Image.find_by(url: original_url) || self.fetch_and_create_original!(url)
  end

  def self.fetch_and_create_original!(url)
    tempfile = Down.download(url, max_size: 10 * 1024 * 1024)  # 10 MB
    im = Image.create!(url: url, format: tempfile.content_type, bin: tempfile.read)
    tempfile.unlink

    im
  end

  def self.create_variant!(original_image, changes, variant_url)
    tf = Tempfile.new([original_image.url, ".jpg"], encoding: 'ascii-8bit') # TODO: create tempfile with correct extension
    tf.write(original_image.bin)
    variant = ImageProcessing::Vips.source(tf.path) # TODO: Source should be a memory buffer - original_image.bin

    # Apply transforms
    changes.each do |cmd, value|
      case cmd
      when "rotate"
        variant = variant.rotate(value.to_i)
      when "crop"
        x, x2, y, y2 = value.split(",")
        variant = variant.crop(x.to_i, x2.to_i, y.to_i, y2.to_i)
      when "resize"
        x,y = value.split(",")
        variant = variant.resize_to_limit(x.to_i, y.to_i)
      when "quality"
        variant = variant.saver(quality: value.to_i)
      end
    end
    # End transforms

    variant_tf = variant.call
    variant_image = Image.create!(url: variant_url, format: original_image.format, bin: variant_tf.read)
    variant_tf.unlink

    variant_image
  end
end
