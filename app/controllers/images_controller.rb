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
