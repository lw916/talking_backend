# encoding:utf-8
# @Author: Wayne
# @Date: 2021-9-6
# 后台消息记录

class VoiceJob < ApplicationJob
  queue_as :default

  def perform(data, current_user)
    # Do something later
    channel = Channel.find(data["channel_id"]) # 查找该频道
    unless channel.id.blank? # 若该频道存在时
      Message.create(
        message: data[:voice],
        status: 1,
        username: current_user[:username]
      ) # 数据库存入语音消息
    end
  end

end
