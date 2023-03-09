class ImageManager
  attr_reader :url, :changes

  def initialize(url, changes={})
    @url = url
    @changes = changes
  end

  def call
    if @changes.any?
      variant_url = @url + "?" + @changes.sort.map{|k,v| "#{k}=#{v}" }.join("&")
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
    vips_image = variant.apply(changeset).call(save: false)

    mem_target = Vips::Target.new_to_memory
    vips_image.write_to_target(mem_target, original_image.format_to_extension)
    Image.create!(url: variant_url, format: original_image.format, bin: mem_target.get("blob"))
  end

  def changeset
    changeset = {}
    @changes.each do |cmd, value|
      if value =~ /,/
        changeset[cmd] = value.split(",").map(&:to_i)
      elsif cmd == "quality"
        changeset['saver'] = {quality: value.to_i}
      else
        changeset[cmd] = value.to_i
      end
    end
    changeset
  end
end
