class NotifyController < ApplicationController

  # 创建修改内容
  def create
    # 判断用户id是否为空
    if notify_params[:user_id].blank?
      render :json => { :status => -1, :msg => '传入的用户id为空' }
      return
    end

    # 判断必填项是否为空
    if notify_params[:type].blank? and notify_params[:content].blank?
      render :json => { :status => -2, :msg => '必填项为空' }
      return
    end

    @notify = Notify.new(:user_id => notify_params['user_id'], :type => notify_params[:type], :content => notify_params[:content])
    if @notify.save!
      render :json => { :status => 1, :msg => '提交修改成功' }
    else
      render :json => { :status => 0, msg => '提交修改失败,请检查后台配置' }
    end


  end

  # 获取修改内容
  def index
    @notify = Notify.find_by_sql('');
    
  end

  private
  # 安全原因，设置可传入的值
  def notify_params
    params.permit(:user_id, :content, :type)
  end


end
