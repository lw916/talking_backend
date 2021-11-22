class UserController < ApplicationController

  def return_all
    users = User.all
    avatar = {}
    users.each do |item|
      avatar[item.id] = item.avatar
    end
    render :json => { :status => 1, :msg => "获取所有人头像成功", :avatar => avatar  }
  end

  def return_avatar
    if params[:id].blank?
      render :json => { :status => -1, :msg => "未传入用户id", :avatar => "" }
      return
    end
    @user = User.find(params[:id])
    if @user.blank?
      render :json => { :status => 0, :msg => "找不到该用户", :avatar => "" }
      nil
    else
      render :json => { :status => 1, :msg => "已返回用户头像信息", :avatar => @user.avatar }
      nil
    end
  end

end
