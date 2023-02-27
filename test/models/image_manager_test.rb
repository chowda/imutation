require "test_helper"

class ImageManagerTest < ActiveSupport::TestCase
  test "fetch existing record instead of remote" do
    image = Image.create!(url: "test")
    assert_equal ImageManager.call("test", {}), image
  end

  test "fetch remote image if it doesn't exist in DB" do
    assert Image.find_by(url: "test") == nil

    tf = Minitest::Mock.new()
    tf.expect(:content_type, "image/jpg")
    tf.expect(:read, "---")
    tf.expect(:unlink, true)

    im = Down.stub(:download, tf) do
      ImageManager.call("test", {})
    end

    assert_equal Image.find_by(url: "test"), im
  end
end
