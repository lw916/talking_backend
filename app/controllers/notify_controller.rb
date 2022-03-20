class NotifyController < ApplicationController

  # 创建修改内容
  def create
    # 判断用户id是否为空
    if notify_params[:user_id].blank?
      render :json => { :status => -1, :msg => '传入的用户id为空' }
      return
    end

    # 判断必填项是否为空
    # content内容为json字符串
    if notify_params[:type].blank? and notify_params[:content].blank?
      render :json => { :status => -2, :msg => '必填项为空' }
      return
    end

    @notify = Notify.new(:user_id => notify_params[:user_id], :type => notify_params[:type], :content => notify_params[:content])
    if @notify.save!
      render :json => { :status => 1, :msg => '提交修改成功' }
    else
      render :json => { :status => 0, msg => '提交修改失败,请检查后台配置' }
    end

  end

  # 获取修改内容
  def index

    # 判断是否传入时间戳，若是则按时间戳返回内容，否则按常量设定值返回内容
    if notify_params[:created_at].blank?
      timeStamp = Time.now.to_i + Const.NOTIFY_REQUEST_TIME
    else
      timeStamp = notify_params[:created_at]
    end

    # 查询通知表中按时间戳返回的内容是否为空
    @notify = Notify.return_change_list(timeStamp)

    if @notify.blank?
      render :json => { :status => 0, :msg => '提醒表中内容为空，无更新项目', :content_list => nil  }
    else
      render :json => { :status => 1, :msg => '提醒表中有数据，需要更新配置表', :content_list => @notify  }
    end
    
  end

  # 删除修改内容（后台任务）
  # 用于定期清除提醒表内容
  def delete

  end

  private
  # 安全原因，设置可传入的值
  def notify_params
    params.permit(:user_id, :content, :type, :created_at)
  end


end
