class ImagesController < ApplicationController
  before_action :require_url, only: [:show]

  def show
    image = Image.find_or_fetch(params.fetch(:url))
    if image.is_a? Image
      send_data(image.data, type: image.format, disposition: 'inline')
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
end
