class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable

  private

  def render_not_found(error)
    render json: ErrorSerializer.format_error(error.message, 400), status: :bad_request
  end
  
  def render_unprocessable(error)
    render json: ErrorSerializer.format_error(error.message, 422), status: :unprocessable_entity
  end
end
