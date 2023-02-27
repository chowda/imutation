class ImageManager
  def initialize(url, changes={})
    @url = url
    @changes = changes
    @original_image = nil
  end

  def call
    # TODO: If this is a variant request, and the variant exists, serve it and skip
    # trying to find the original.
    find_or_fetch_original!

    unless original?
      variant_image = Image.find_by(url: variant_url)
      variant_image = create_variant! unless variant_image
    end

    original? ? @original_image : variant_image
  end

  private

  def find_or_fetch_original!
    original_url = @url.split("?").first
    @original_image = Image.find_by(url: original_url) || fetch_and_create_original!()
  end

  def fetch_and_create_original!
    tempfile = Down.download(@url, max_size: 10 * 1024 * 1024)  # 10 MB
    im = Image.create!(url: @url, format: tempfile.content_type, data: tempfile.read)
    tempfile.unlink

    im
  end

  def create_variant!
    tf = Tempfile.new([@original_image.url, ".jpg"], encoding: 'ascii-8bit') # TODO: create tempfile with correct extension
    tf.write(@original_image.data)
    variant = ImageProcessing::Vips.source(tf.path)

    # Apply transforms
    @changes.each do |cmd, value|
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
    variant_image = Image.create!(url: variant_url, format: @original_image.format, data: variant_tf.read)
    variant_tf.unlink

    variant_image
  end

  def original?
    @original ||= @changes.empty?
  end

  def variant_url
    @variant_url ||= @url + "?" + @changes.map{|k,v| "#{k}=#{v}" }.join("&")
  end
end
