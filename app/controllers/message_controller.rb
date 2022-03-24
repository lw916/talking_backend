class MessageController < ApplicationController

  skip_before_action :verify_authenticity_token

  # 获取信息列表
  # 查询是否有限制条件
  def index

    if http_token
      render :json => { :status => 4000, :msg => '无token拒绝请求' }
      return
    end

    # if payload['utype'] != 'admin'
    #   render :json => { :status => 4001, :msg => '无权限拒绝请求' }
    #   return
    # end

    sql = 'select * from messages '
    # 判断是否有用户名
    unless message_params[:username].blank?
      sql << "where username = '#{message_params[:username]}' "
    end
    # 判断是否有频道id
    unless message_params[:channel_id].blank?
      sql << "and channel_id = #{message_params[:channel_id]} "
    end

    @message_list = Message.find_by_sql(sql)
    if @message_list.blank?
      render :json => { :status => 0, :msg => '根据提供的筛选信息，信息列表为空', :messages => nil }
    else
      render :json => { :status => 1, :msg => '请求成功', :messages => @message_list }
    end
  end

  # 获取token
  def http_token
    @http_token ||= request.headers['token'] or request.params['token']
  end

  # 解析token获取信息
  def payload
    @payload ||= Token.decode(@http_token)
  end


  private
  # 安全原因，设置可传入的值
  def message_params
    params.permit(:username, :channel_id )
  end

end
