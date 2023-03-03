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
    tf = Minitest::Mock.new()
    tf.expect(:content_type, @media_type)
    tf.expect(:read, @data)
    tf.expect(:unlink, true)

    Down.stub(:download, tf) do
      get image_show_url, params: {url: @url}
    end
    assert_equal @data, @response.body
  end

  test "#show without required url param" do
    get image_show_url, params: {url: nil}
    assert_equal "URL is required", @response.body
  end

  test "#show with exception thrown" do
    ImageManager.stub(:call, Down::TimeoutError.new) do
      get image_show_url, params: {url: @url}
    end
    assert_equal "Timeout fetching image from origin", @response.body
  end

  test "#help" do
    get image_help_url
    assert_equal @response.code, '200'
  end
end
