class TalkingChannel < ApplicationCable::Channel

  # 连接type:
  # Ping, user_disconnect, user_connect, user_in, user_out, message, audio, talking, isTalking, errorChannel, voice_over, userListSuccess, userListFail

  # 用户登录成功，订阅用户频道
  def subscribed

    stop_all_streams # 进入新频道前，停止所有其他频道的串流
    stream_from "channel_#{params[:channel_id]}" # 公共频道（含语音，可文字）
    stream_from "channel_person_#{current_user[:user_id]}" # 个人频道（用于心跳连接检测是否断连，当前频道有人讲话时占用频道）

    if validate_params
      # 判断连接用户是否合法
      # 订阅测试用例：{"command":"subscribe","identifier":"{\"channel\":\"TalkingChannel\",\"channel_id\":2}"}
      if current_user
        keep_alive
        user_online
        ping
        notification("in") # 提示用户进入房间/频道
      end
    else
      unsubscribed
    end

  end

  # 取消订阅测试用例：{"command":"unsubscribe","identifier":"{\"channel\":\"TalkingChannel\",\"channel_id\":2}"}
  def unsubscribed
    # 停止频道的所有串流
    stop_all_streams
    user_offline
    ActionCable.server.remote_connections.where(current_user: current_user).disconnect # 断连该用户
  end

  def list
    validate_params # 验证输入表单
    user_list # 验证成功返回数据
  end

  # 占用频道禁止其他用户通话
  def talking
    # 查询通话锁
    user = $Talk_lock.get(params[:channel_id])
    if user.blank? # 判断用户锁
      # 无用户所使用锁，设定用户锁
      if $Talk_lock.set(params[:channel_id], current_user[:username])
        # 根据频道设置的最大可通话时长设置redis有效时间，防止用户占茅坑不拉屎行为
        $Talk_lock.expire(params[:channel_id], Const::MAX_TALKING_SECOND+5)
        ActionCable.server.broadcast "channel_#{params[:channel_id]}",
                                     type: "talking",
                                     code: 1,
                                     max_talking: Const::MAX_TALKING_SECOND,
                                     msg: "#{current_user[:user_id]}正在讲话"
      else
        # 设定用户锁失败，释放频道锁
        release_channel
      end
    else
      # 通过个人频道通知用户有人讲话中，禁止占用频道
      transmit type: "isTalking", code: -1, action: "occupy", # 动作：占用
                                   msg: "用户#{user}正在讲话"
    end
  end

  # 讲话完毕，语音消息发送调用函数
  def talk(data)
    data = HashWithIndifferentAccess.new(data)
    puts data
    if data[:channel_id].blank?
      transmit type: "errorChannel", msg: "频道id为空"
    else
      ActionCable.server.broadcast "channel_#{data[:channel_id]}",
                                   type: "audio", # 动作： 语音消息
                                   msg: "#{current_user[:user_id]}发了一段语音",
                                   voice: data[:voice]
      over(data[:channel_id])
      MessageRecordJob.perform_later(data, current_user)
    end

  end

  # {"command":"message","identifier":"{\"channel\":\"TalkingChannel\",\"channel_id\":1}","data":"{\"action\":\"pong\"}"}
  # 回复ping
  def pong
    keep_alive
  end

  def msg(data)
    ActionCable.server.broadcast "channel_#{data["channel_id"]}",
                                 to: "#{data["to"]}",
                                 type: "message",
                                 msg_type: "#{data["type"]}",
                                 content: data["content"]
  end

  # 通话结束
  def over(channel_id)
    if $Talk_lock.del(channel_id)
      ActionCable.server.broadcast "channel_#{channel_id}",
                                   type: "voice_over", # 动作：停止讲话
                                   msg: "通话结束",
                                   user: current_user[:user_id]
    end
  end

  # 判断表单内容是否正确
  def validate_params
    # 判断是否传入频道id
    if params[:channel_id].blank?
      transmit type: "errorChannel", code: Const::SUBSCRIBE_CHANNEL_BLANK, msg: "频道id为空"
      false
    else
      begin
        # 判断频道id是否存在
        Channel.find(params[:channel_id])
        true
      rescue ActiveRecord::RecordNotFound
        transmit type: "errorChannel", code: Const::SUBSCRIBE_CHANNEL_NOT_EXIST, msg: "频道不存在，请检查频道id"
        false
      end

    end
  end

  # 设置用户状态
  def set_user_status(channel_id, status)

    # 获取当前用户列表，不存在则创建
    if Rails.cache.read(channel_id).blank?
      list = {}
    else
      list = Rails.cache.read(channel_id)
    end
    # 将用户设置为在线状态
    list[current_user[:username]]= status
    # 写入用户列表缓存中
    Rails.cache.write(channel_id, list)

  end

  # 用户上线时：
  def user_online
    set_user_status(params[:channel_id], true)
    $Connection_lock.set(current_user[:user_id], true)
  end

  # 用户下线设置
  def user_offline
    $Connection_lock.del(current_user[:user_id])
    set_user_status(params[:channel_id], false)
    notification("out") # 提示用户离开房间/频道
    transmit type: "user_out", msg: "断开连接成功"
    ActionCable.server.remote_connections.where(current_user: current_user).disconnect
  end

  # 获取当前频道的在线用户列表
  def user_list
    begin
      # 获取用户列表
      puts params[:channel_id]
      user_list = Rails.cache.read(params[:channel_id])
      puts Rails.cache.read(params[:channel_id])

      # 返回用户列表
      transmit type: "userListSuccess", msg: "获取在线用户列表成功", user_list: user_list.to_json
    rescue
      transmit type: "userListFail", msg: "获取在线用户列表失败", user_list: nil
    end
  end

  private

  # 告知全体频道的人员出入情况
  def notification(status)
    if status == "in"
      ActionCable.server.broadcast "channel_#{params[:channel_id]}",
                                   type: "user_in",
                                   msg: "#{current_user[:username]} 进入了频道"
    else
      ActionCable.server.broadcast "channel_#{params[:channel_id]}",
                                   type: "user_out",
                                   msg: "#{current_user[:username]} 离开了频道"
    end
  end

  # 查询用户在线状态
  def user_online?
    user_list = Rails.cache.read(params[:channel_id]) # 获取用户在线信息
    if user_list.blank? # 当用户列表不存在时
      false
    else
      user_list[current_user[:username]]
    end
  end

  # 设置用户答复ping时间
  def keep_alive
    $Online_time.set(current_user[:username], Time.now.to_i)
  end

  # 判断用户是否在线（3次ping-pong）
  def alive?
    Time.now.to_i - $Online_time.get(current_user[:username]).to_i < 10
  end

  # 释放频道语音锁
  def release_channel
    # 频道为当前用户占用时解除占用并广播
    if $Talk_lock.get(params[:channel_id]) == current_user[:user_id]
      ActionCable.server.broadcast "channel_#{params[:channel_id]}",
                                   type: "user_disconnect",
                                   msg: "用户断线，对讲语音数据丢失",
                                   user: current_user[:username] if $Talk_lock.del(params[:channel_id])
    end
  end

  # ping-pong ping方法（设置ping时间为4秒，超时三次未接受掉线）
  def ping
    Thread.new do
      while user_online? do
        if alive?
          transmit type: "PING", msg: "PING", timestamp: Time.now.to_i
          sleep 3
        else
          user_offline
          ActionCable.server.remote_connections.where(current_user: current_user).disconnect
          Thread.exit
        end
      end
      release_channel
      Thread.exit
    end
  end

end
