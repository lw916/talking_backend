class Token

  # 生成token
  def self.encode(payload)
    payload.merge!(exp:(Time.now.to_i + Const::TOKEN_EXPIRE_TIME))
    token = JWT.encode(payload, Const::JWT_KEY)
    return token
  end

  # 解析token
  def self.decode(token)
    payload = HashWithIndifferentAccess.new(JWT.decode(token,Const::JWT_KEY)[0])
    return payload
  rescue JWT::DecodeError,JWT::ExpiredSignature
    return nil
  end

end