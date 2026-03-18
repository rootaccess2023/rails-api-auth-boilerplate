class Api::V1::BaseController < ActionController::API
  def authenticate_user!
    token   = extract_token_from_header
    payload = JsonWebToken.decode(token)
    @current_user = User.find(payload[:user_id])
  rescue JWT::DecodeError, ActiveRecord::RecordNotFound
    render json: { error: "Unauthorized" }, status: :unauthorized
  end

  def current_user
    @current_user
  end

  private

  def extract_token_from_header
    header = request.headers["Authorization"]
    raise JWT::DecodeError, "No token" unless header&.start_with?("Bearer ")
    header.split(" ").last
  end
end