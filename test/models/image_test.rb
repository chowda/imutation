require "test_helper"

class ImageTest < ActiveSupport::TestCase
  test "unique url" do
    Image.create!(url: "test")
    assert_raises(ActiveRecord::RecordInvalid) do
      Image.create!(url: "test")
    end
  end
end
