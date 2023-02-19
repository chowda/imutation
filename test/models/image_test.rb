require "test_helper"

class ImageTest < ActiveSupport::TestCase
  test "fetch existing record instead of remote" do
    image = Image.create!(url: "test")
    assert Image.find_or_fetch("test") == image
  end

  test "fetch remote image if it doesn't exist in DB" do
    assert Image.find_by(url: "test") == nil

    tf = Minitest::Mock.new()
    tf.expect(:content_type, "image/jpg")
    tf.expect(:read, "---")
    tf.expect(:unlink, true)

    Down.stub(:download, tf) do
      Image.find_or_fetch("test")
    end

    assert Image.find_by(url: "test") != nil
  end
end
