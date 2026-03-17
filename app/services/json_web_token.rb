class JsonWebToken
  SECRET_KEY = ENV.fetch("JWT_SECRET_KEY") { raise "JWT_SECRET_KEY is not set!" }
  EXPIRY     = 30.days

  # Create a signed token containing the payload
  def self.encode(payload, exp = EXPIRY.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY, "HS256")
  end

  # Verify and decode a token — raises if invalid or expired
  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY, true, algorithm: "HS256")
    HashWithIndifferentAccess.new(decoded.first)
  rescue JWT::ExpiredSignature
    raise JWT::DecodeError, "Token has expired"
  rescue JWT::DecodeError => e
    raise JWT::DecodeError, "Invalid token: #{e.message}"
  end
end