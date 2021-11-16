class ApplicationController < ActionController::Base

  # 通过token获取username
  def get_username_by_token
    token ||= if request.headers['token'].present?
                request.headers['token']
              end
    if token.blank?
      return "未知用户"
    end
    payload = Token.decode(token)
    payload["username"]
  end

  def authenticate!
    unless token?
      render :json => {
        :code => "400",
        :msg => "token不存在或者已经过期"
      }
    end
  end

  private
  # 通过前端发来的header获取token
  def get_token
    @token ||=  if request.headers['token'].present?
                  request.headers['token']
                end
  end

  # 验证token有效性及是否过期
  def auth_token
    @auth_token ||= Token.decode(get_token)
  end

  # 验证token中的信息是否正确
  def token?
    get_token && auth_token
  end

  # 生成Token
  def generate_token(payload)
    @token ||= Token.encode(payload)
  end

end
