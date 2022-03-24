class SendController < ApplicationController

  skip_before_action :verify_authenticity_token

  # 发消息
  def index

    # 判断类型与内容是否为空
    if message_params["type"].blank? or message_params["content"].blank?
      render :json => { :status => 2000, :msg => '未传入信息类型或信息内容' }
      return
    end

    # 判断发送的消息为群组消息还是个人消息
    if !message_params["channel_id"].blank?
      ActionCable.server.broadcast "channel_#{message_params["channel_id"]}",
                                   to: "#{message_params["channel_id"]}",
                                   type: "message",
                                   msg_type: "#{message_params["type"]}",
                                   content: message_params["content"]
      render :json => { :status => 1000, :msg => '成功' }
    elsif !message_params["person"].blank?
      ActionCable.server.broadcast "channel_person_#{message_params["channel_id"]}",
                                   to: "#{message_params["channel_id"]}",
                                   type: "message",
                                   msg_type: "#{message_params["type"]}",
                                   content: message_params["content"]
      render :json => { :status => 1000, :msg => '成功' }
    else
      render :json => { :status => 2000, :msg => '未传入群组id或用户id' }
    end

  end

  private
  # 安全原因，设置可传入的值
  def message_params
    params.permit(:send, :channel_id, :type, :content, :person)
  end

end