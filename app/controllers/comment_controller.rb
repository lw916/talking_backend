class CommentController < ApplicationController

  before_action :authenticate!
  skip_before_action :verify_authenticity_token

  def index
    comments = Comment.all
    if comments.blank?
      render :json => { :status => 0, :msg => "用户反馈为空" }
      nil
    else
      render :json => { :status => 0, :msg => "获取用户反馈成功", :comments => comments }
      nil
    end
  end

  def create
    if params[:created_user].blank? or params[:comments].blank?
      render :json => { :status => -1, :msg => "必填项为空" }
      return
    end
    @comment = Comment.new(:created_user => params[:created_user], :comments => params[:comments] )
    if @comment.save!
      render :json => { :status => 1, :msg => "提交建议成功" }
    else
      render :json => { :status => 0, :msg => "提交建议失败" }
    end
  end

end
