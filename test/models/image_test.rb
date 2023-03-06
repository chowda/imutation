require "test_helper"

class ImageTest < ActiveSupport::TestCase
  test "unique url" do
    Image.create!(url: "test")
    assert_raises(ActiveRecord::RecordInvalid) do
      Image.create!(url: "test")
    end
  end

  test "format to extension - image/jpeg" do
    im = Image.new(format: 'image/jpeg')
    assert_equal im.format_to_extension, '.jpg'
  end

  test "format to extension - image/png" do
    im = Image.new(format: 'image/png')
    assert_equal im.format_to_extension, '.png'
  end

  test "format to extension - image/unknown" do
    im = Image.new(format: 'image/unknown')
    assert_equal im.format_to_extension, '.jpg'
  end
end
