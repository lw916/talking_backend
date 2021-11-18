class LoginController < ApplicationController

  skip_before_action :verify_authenticity_token

  # 登录
  def login
    # 账户密码未传入
    if user_params[:username].blank? or user_params[:password].blank?
      render :json => { :status => -1, :msg => "账户或密码未传入" }
      return
    end

    @user = User.find_by_username(user_params[:username])
    # 用户不存在
    if @user.blank?
      render :json => { :status => -2, :msg => "用户不存在" }
      return
    end

    # 账户禁用
    if @user.status != 1
      render :json => { :status => -3, :msg => "账户被封禁" }
      return
    end

    if @user.password == user_params[:password]
      token = Token.encode(
        {
          :username => @user.username,
          :status => @user.status
        }
      )
      render :json => { "status" => 1, :msg => "登陆成功", :token => token, :email => @user.email, :id => @user.id, :avatar => @user.avatar }
      nil
    else
      render :json => { :status => 0, :msg => "密码错误", :token => nil }
      nil
    end

  end

  # 登出
  def logout
    render :json => { :status => 1, :msg => "登出成功" }
  end

  # 重置密码
  def forget
    # 账户邮箱未传入
    if user_params[:username].blank? or user_params[:email].blank? or user_params[:password].blank?
      render :json => { :status => -1, :msg => "账户或密码或邮箱未传入" }
      return
    end

    @user = User.find_by_username(user_params[:username])
    # 用户不存在
    if @user.blank?
      render :json => { :status => -2, :msg => "用户不存在" }
      return
    end

    # 账户禁用
    if @user.status != 1
      render :json => { :status => -3, :msg => "账户被封禁" }
      return
    end

    if @user.username == user_params[:username] and @user.email == user_params[:email]
      @user.password = user_params[:password]
      if @user.save!
        render :json => { :status => 1, :msg => "修改密码成功" }
        return
      else
        render :json => { :status => 0, :msg => "修改密码失败" }
        return
      end
    else
      render :json => { :status => -4, :msg => "用户名与邮箱不匹配" }
      nil
    end

  end

  # 注册用户
  def register
    # 账户邮箱未传入
    if user_params[:username].blank? or user_params[:email].blank? or user_params[:password].blank?
      render :json => { :status => -1, :msg => "账户或密码或邮箱未传入" }
      return
    end

    @user = User.find_by_username(user_params[:username])
    # 用户不存在
    unless @user.blank?
      render :json => { :status => -2, :msg => "用户已存在" }
      return
    end

    if User.create(:username => user_params[:username], :password => user_params[:password], :email => user_params[:email], :status => 1, :avatar => Const::DEFAULT_AVATAR)
      render :json => { :status => 1, :msg => "注册成功" }
      nil
    else
      render :json => { :status => 0, :msg => "注册失败" }
      nil
    end
  end

  # 重置密码
  def reset
    if user_params[:username].blank? or user_params[:password].blank?
      render :json => { :status => -1, :msg => "账户或密码未传入" }
      return
    end

    @user = User.find_by_username(user_params[:username])
    # 用户不存在
    if @user.blank?
      render :json => { :status => -2, :msg => "用户不存在" }
      return
    end

    @user.password = user_params[:password]
    if @user.save!
      render :json => { :status => 1, :msg => "修改密码成功" }
      nil
    else
      render :json => { :status => 0, :msg => "修改密码错误" }
      nil
    end
  end

  # 上传头像
  def upload_avatar
    if user_params[:id].blank? or user_params["avatar"].blank?
      render :json => { :status => -1, :msg => "账户id未传或用户头像未传" }
      return
    end

    @user = User.find_by(user_params["id"])
    if @user.blank?
      render :json => { :status => -2, :msg => "没有该用户" }
      return
    end

    @user.avatar = user_params["avatar"]
    if @user.save!
      render :json => { :status => 1, :msg => "上传成功", :avatar => @user.avatar }
      nil
    else
      render :json => { :status => 0, :msg => "后台系统错误" }
      nil
    end
  end

  # 获取头像信息
  def avatar
    if user_params[:id].blank?
      render :json => { :status => -1, :msg => "账户id未传或用户头像未传", :avatar => nil }
      return
    end
    @user = User.find_by(user_params["id"])
    if @user.blank?
      render :json => { :status => -2, :msg => "没有该用户", :avatar => nil }
      return
    end
    if @user.avatar.blank?
      render :json => { :status => 0, :msg => "该用户没有头像", :avatar => nil }
      nil
    else
      render :json => { :status => 1, :msg => "获取头像成功", :avatar => @user.avatar }
    end
  end

  private
  # 安全原因，设置可传入的值
  def user_params
    params.permit(:username, :password,:email, :id, :avatar)
  end


end
