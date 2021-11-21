class UserController < ApplicationController

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
