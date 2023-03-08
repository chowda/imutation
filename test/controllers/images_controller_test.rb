require "test_helper"

class ImagesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @media_type = 'image/jpg'
    @url = 'https://foo.bar/images/1.jpg'
    @data = '---'
  end

  test "#show with legit image already in DB" do
    Image.create!(url: @url, format: @media_type, bin: @data)
    get image_show_url, params: {url: @url}

    assert_equal @data, @response.body
    assert_equal @media_type, @response.media_type
  end

  test "#show with legit image not already in DB" do
    tf = mock()
    tf.expects(:content_type).returns(@media_type)
    tf.expects(:read).returns(@data)
    tf.expects(:unlink).returns(true)

    Down.stub(:download, tf) do
      get image_show_url, params: {url: @url}
    end
    assert_equal @data, @response.body
  end

  test "#show without required url param" do
    get image_show_url, params: {url: nil}
    assert_equal "URL is required", @response.body
  end

  test "#show with TimeoutError exception thrown" do
    Down.expects(:download).raises(Down::TimeoutError)
    get image_show_url, params: {url: @url}
    assert_equal "TimeoutError", @response.body
  end

  test "#show with TooLarge exception thrown" do
    Down.expects(:download).raises(Down::TooLarge)
    get image_show_url, params: {url: @url}
    assert_equal "TooLarge", @response.body
  end

  test "#help" do
    get image_help_url
    assert_equal @response.code, '200'
  end
end
