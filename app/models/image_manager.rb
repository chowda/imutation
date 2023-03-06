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
    # TODO: ImageProcessing::Vips.valid_image?(normal_image)  #=> true
    #       ImageProcessing::Vips.valid_image?(invalid_image) #=> false
    #       Tries to calculate the image average using sequential access, and returns true if no exception was raised, otherwise returns false.
    im = Image.create!(url: url, format: tempfile.content_type, bin: tempfile.read)
    tempfile.unlink

    im
  end

  def self.create_variant!(original_image, changes, variant_url)
    variant = ImageProcessing::Vips.source(Vips::Image.new_from_buffer(original_image.bin, ""))

    # Apply transforms
    # TODO: Can I do them all with 1 apply? https://github.com/janko/image_processing/blob/master/doc/vips.md#apply
    changes.each do |cmd, value|
      case cmd
      when "resize_to_limit" # Downsizes the image to fit within the specified dimensions while retaining the original aspect ratio. Will only resize the image if it's larger than the specified dimensions.
        h, w = value.split(",")
        variant = variant.resize_to_limit(h.to_i, w.to_i)
      when "resize_to_fit" # Resizes the image to fit within the specified dimensions while retaining the original aspect ratio. Will downsize the image if it's larger than the specified dimensions or upsize if it's smaller.
        h, w = value.split(",")
        variant = variant.resize_to_fit(h.to_i, w.to_i)
      when "resize_to_fill" # Resizes the image to fill the specified dimensions while retaining the original aspect ratio. If necessary, will crop the image in the larger dimension.
        h, w = value.split(",")
        variant = variant.resize_to_fill(h.to_i, w.to_i, crop: :attention) # smart crop
      when "crop" # Extracts an area from an image. The first two arguments are left & top edges of area to extract, while the last two arguments are the width & height of area to extract.
        l, t, w, h = value.split(",")
        variant = variant.crop(l.to_i, t.to_i, w.to_i, h.to_i)
      when "rotate" # Rotates the image by the specified angle.
        variant = variant.rotate(value.to_i)
      when "quality"
        variant = variant.saver(quality: value.to_i)
      end
    end
    # End transforms
    vips_image = variant.call(save: false)

    mem_target = Vips::Target.new_to_memory
    vips_image.write_to_target(mem_target, original_image.format_to_extension)
    # TODO: ImageProcessing::Vips.valid_image?(normal_image)  #=> true
    #       ImageProcessing::Vips.valid_image?(invalid_image) #=> false
    #       Tries to calculate the image average using sequential access, and returns true if no exception was raised, otherwise returns false.
    Image.create!(url: variant_url, format: original_image.format, bin: mem.get("blob"))
  end
end
