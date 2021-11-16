class ChannelController < ApplicationController
  before_action :authenticate!

  # 返回所有频道：
  def index
    list = Channel.all # 数据库获取频道所有信息
    channel_list = []
    if list.blank? # 若频道列表为空
      render :json => { :code => 0, :msg => "频道列表为空，请创建频道", :channel_list => nil }
    else
      list.each do |item| # 遍历数据库获取信息
        channel_list.append(
          {
            "id" => item.id, # 频道id
            "channel_name" => item.channel_name, # 频道名
            "maximum_talking" => item.maximum_talk, # 最长可通话时长
            "status" => item.status, # 频道状态
            "create_at" => item.created_at # 创建时间
          }
        )
      end
      render :json => { :code => 1, :msg => "获取频道信息成功", :channel_list => channel_list }
    end
  end


  # 创建新频道
  def create
    # 判断传入值是否为空值
    if params[:channel_name].blank? or params[:maximum_talk].blank? or params.blank?
      render :json => { :code => -1, :msg => "必填值为空" }
      return
    end

    # 房间名是否重名
    unless Channel.where(:channel_name => params[:channel_name]).blank?
      render :json => { :code => -2, :msg => "频道名重名" }
      return
    end

    # 创建房间
    @channel = Channel.new( :channel_name => params[:channel_name],
                            :maximum_talk => params[:maximum_talk],
                            :status => 1)
    if @channel.save!
      render :json => { :code => 1, :msg => "频道创建成功" }
    else
      render :json => { :code => 0, :msg => "无法创建频道,需检查变量名" }
    end
  end

  # 修改房间信息
  def update

    # 频道id未传入不允许修改
    if params[:id].blank?
      render :json => { :code => -1, :msg => "未传入频道id" }
    end

    # 三项均不修改不允许后台操作
    if params[:channel_name].blank? and params[:maximum_talk].blank? and params[:status].blank?
      render :json => { :code => -2, :msg => "未有修改项，禁止修改频道信息" }
      return
    end

    # 修改频道信息，返回json结果
    if Channel.update(user_params)
      render :json => { :code => 1, :msg => "修改成功" }
    else
      render :json => { :code => 0, :msg => "修改失败，请检查修改项" }
    end

  end

  # 删除频道
  def destroy
    # 检测传入频道id是否存在
    if params[:id].blank?
      render :json => { :code => -1, :msg => "请提供删除频道id" }
      return
    end

    #根据频道id查询频道是否存在以及是否存在历史语音消息
    begin
      @channel = Channel.find(params[:id])
      if @channel.messages.length > 0
        render :json => { :code => -3, :msg => "频道存在历史语音消息禁止删除" }
      else
        @channel.destroy
        render :json => { :code => 1, :msg => "删除频道成功" }
      end
    rescue
      render :json => { :code => -2, :msg => "频道不存在" }
    end

  end

  # 频道暂停使用
  def suspend
    # 频道不存在
    if params[:id].blank?
      render :json => { :code => -1, :msg => "频道id未传或不存在该频道" }
      return
    end
    @channel = Channel.find(params[:id]).blank?
    if @channel.blank?
      render :json => { :code => -2, :msg => "频道不存在" }
    end

    # 设置频道状态为暂停
    if @channel.update(params[:id], :status => 0)
      render :json => { :code => 1, :msg => "频道已暂停使用" }
    else
      render :json => { :code => 0, :msg => "频道暂停使用失败" }
    end
  end

  # 启用频道
  def start
    # 频道不存在
    if params[:id].blank?
      render :json => { :code => -1, :msg => "频道id未传" }
    end

    @channel = Channel.find(params[:id]).blank?
    if @channel.blank?
      render :json => { :code => -2, :msg => "频道不存在" }
    end

    # 设置频道状态为启用
    if @channel.update(params[:id], :status => 1)
      render :json => { :code => 1, :msg => "频道已启用" }
    else
      render :json => { :code => 0, :msg => "频道启用失败" }
    end
  end


  # 安全原因，设置可传入的值
  def user_params
    params.permit(:channel_name, :status, :maximum_talk)
  end


end
