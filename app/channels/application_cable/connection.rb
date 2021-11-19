# encoding:utf-8
# @Author: Wayne
# @Date: 2021-7-20
# WS连接验证

module ApplicationCable

  # token临时生成：JWT.encode({'username':'liwei','user_id':1}, Rails.application.secrets.secret_key_base)
  # eyJhbGciOiJIUzI1NiJ9.eyJ1c2VybmFtZSI6Imxpd2VpIiwidXNlcl9pZCI6MX0.UB9b_tYBBZ9HHsD9DjVHiqdGsScoAg0tLtMDChXEVq4

  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    # 用户连接时:
    def connect
      # 验证用户token信息 / 将token信息传入变量中
      self.current_user = get_user_detail
    end

    # 用户断连时
    def disconnect
      user_disconnect # 用户断开ws连接是删除用户登陆锁
    end

    protected

    # 自定义心跳连接函数
    def beat
      # transmit( type: ActionCable::INTERNAL[:message_types][:ping], message: Time.now.to_i )
    end

    # 获取用户信息，并判断用户是否已经登陆
    def get_user_detail
      puts http_token
      puts payload
      # 判断token是否存在/token是否有效/token是否携带用户信息
      if http_token.blank? or !payload or !payload[:username].to_s
        transmit( code: Const::CONNECTION_AUTHENTICATION_FAIL, msg: "未认证用户" )
        websocket.close
        # 判断当前用户是否登陆
      elsif not $Connection_lock.get(payload[:user_id]).blank?
        transmit( code: Const::IS_LOGIN, type: "isLogin", msg: "该用户已登录，不允许多点登录" )
        websocket.close # 断连该用户
      end
      payload
    end

    # 断开连接时需要操作函数
    def user_disconnect
      # 用户锁解除 / 防止挤号
      # if self.current_user
      #   $Connection_lock.del(self.current_user[:user_id])
      # end
    end

    # 获取token
    def http_token
      @http_token ||= request.headers['token'] or request.params['token']
    end

    # 解析token获取信息
    def payload
      @payload ||= Token.decode(http_token)
    end

  end

end
