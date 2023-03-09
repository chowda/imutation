class ImageManager
  attr_reader :url, :changes

  def initialize(url, changes={})
    @url = url
    @changes = changes
  end

  def call
    if @changes.any?
      variant_url = @url + "?" + @changes.map{|k,v| "#{k}=#{v}" }.join("&")
      variant_image = Image.find_by(url: variant_url)
      unless variant_image
        original_image = find_or_fetch_original!()
        variant_image = create_variant!(original_image, variant_url)
      end
      variant_image
    else
      find_or_fetch_original!()
    end
  end

  private

  def find_or_fetch_original!()
    original_url = @url.split("?").first
    Image.find_by(url: original_url) || fetch_and_create_original!()
  end

  def fetch_and_create_original!()
    tempfile = Down.download(@url, max_size: 10 * 1024 * 1024)  # 10 MB
    im = Image.create!(url: @url, format: tempfile.content_type, bin: tempfile.read)
    tempfile.unlink

    im
  end

  def create_variant!(original_image, variant_url)
    variant = ImageProcessing::Vips.source(Vips::Image.new_from_buffer(original_image.bin, ""))

    # Build up transform changeset
    changeset = {}
    @changes.each do |cmd, value|
      case cmd
      when "resize_to_limit" # Downsizes the image to fit within the specified dimensions while retaining the original aspect ratio. Will only resize the image if it's larger than the specified dimensions.
        h, w = value.split(",")
        changeset[:resize_to_limit] = [h.to_i, w.to_i]
      when "resize_to_fit" # Resizes the image to fit within the specified dimensions while retaining the original aspect ratio. Will downsize the image if it's larger than the specified dimensions or upsize if it's smaller.
        h, w = value.split(",")
        changeset[:resize_to_fit] = [h.to_i, w.to_i]
      when "resize_to_fill" # Resizes the image to fill the specified dimensions while retaining the original aspect ratio. If necessary, will crop the image in the larger dimension.
        h, w = value.split(",")
        changeset[:resize_to_fill] = [h.to_i, w.to_i]
      when "crop" # Extracts an area from an image. The first two arguments are left & top edges of area to extract, while the last two arguments are the width & height of area to extract.
        l, t, w, h = value.split(",")
        changeset[:crop] = [l.to_i, t.to_i, w.to_i, h.to_i]
      when "rotate" # Rotates the image by the specified angle.
        changeset[:rotate] = value.to_i
      when "quality"
        changeset[:saver] = {quality: value.to_i}
      end
    end
    vips_image = variant.apply(changeset).call(save: false)

    mem_target = Vips::Target.new_to_memory
    vips_image.write_to_target(mem_target, original_image.format_to_extension)
    Image.create!(url: variant_url, format: original_image.format, bin: mem_target.get("blob"))
  end
end
