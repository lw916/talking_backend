# encoding:utf-8
# @Author: Wayne
# @Date: 2022-3-22
# 后台消息记录

class MessageJob < ApplicationJob
  queue_as :default

  def perform(data, current_user)
    # Do something later
    channel = Channel.find(data["channel_id"]) # 查找该频道
    unless channel.id.blank? # 若该频道存在时
      Message.create(
        channel_id: data["channel_id"],
        message: data["content"],
        status: 1,
        username: current_user[:username]
      ) # 数据库存入文字消息
    end
  end

end

