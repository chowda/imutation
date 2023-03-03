class ImagesController < ApplicationController
  before_action :require_url, only: [:show]
  after_action :log_request, only: [:show]

  def show
    image = ImageManager.call(params[:url], permitted_params.except(:url))
    if image.is_a? Image
      send_data(image.bin, type: image.format, disposition: 'inline')
    elsif image.is_a? Down::TimeoutError
      render_error("Timeout fetching image from origin")
    else
      render_error("ERROR")
    end
  end

  def help
    help = """
    Available commands:

    resize_to_limit - Downsizes the image to fit within the specified dimensions while retaining the original aspect ratio. Will only resize the image if it's larger than the specified dimensions.

    resize_to_fit -   Resizes the image to fit within the specified dimensions while retaining the original aspect ratio. Will downsize the image if it's larger than the specified dimensions or upsize if it's smaller.

    resize_to_fill -  Resizes the image to fill the specified dimensions while retaining the original aspect ratio. If necessary, will crop the image in the larger dimension.

    crop -            Extracts an area from an image. The first two arguments are left & top edges of area to extract, while the last two arguments are the width & height of area to extract.

    rotate -          Rotates the image by the specified angle. (1 - 359)

    quality -         Sets the image quality. 1 is maximum compression, 100 is full quality. (1 - 100)
    """

    render plain: help
  end

  private

  def render_error(message)
    render plain: message, status: 500
  end

  def require_url
    render_error("URL is required") if params[:url].nil?
  end

  def log_request
    LogRequestJob.perform_later(
      {
        url: request.url,
        referer: request.referer,
        host: request.host,
        requested_at: Time.now.utc
      }
    )
  end

  def permitted_params
    params.permit(
      :url,
      :resize_to_limit,
      :resize_to_fit,
      :resize_to_fill,
      :crop,
      :rotate,
      :quality
    ).to_h
  end
end
