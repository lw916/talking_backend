class LogController < ApplicationController
  require 'tempfile'
  skip_before_action :verify_authenticity_token

  # 获取所有日志内容
  # 日志所有字段：
  # roles username ip_addr action_type created_user updated_user
  def index

    # 默认第一页
    pageNum = 0
    # 获取log的条数
    sqlCount = 'SELECT COUNT(1) as count FROM `logs`'

    # 设置sql语句
    sql = 'select * from logs '

    unless params[:page_num].blank?
      json = ParamsJudge.page_judge(params[:page_num])
      unless json.blank?
        render :json => json
        return
      end
      # 传入值无误，赋值
      pageNum = params[:page_num].to_i - 1
    end

    # 用户名作为限制条件
    unless params[:username].blank?
      sql << "where username like '#{params[:username]}' "
    end

    # ip地址作为限制条件
    unless params[:ip].blank?
      sql << "where ip_addr like '#{params[:ip]}' "
    end

    # 创建者作为限制条件
    unless params[:created_user].blank?
      sql << "where created_user like '#{params[:created_user]}' "
    end

    # 获取搜索数据库分页sql语句
    sql << "order by id desc limit #{Const::LOG_NUM * pageNum},#{Const::LOG_NUM} "

    @logs_count = Log.find_by_sql(sqlCount)
    if @logs_count[0].count == 0
      render :json => { :status => Const::LOG_RESPONSE_BLANK, :msg => '日志表数据为空', :total_num => @logs_count[0].count, :num_per_page => Const::LOG_NUM, :log_list => nil }
    else
      # 查询数据库获取日志信息
      @logs = Log.find_by_sql(sql)
      if @logs.blank?
        render :json => { :status => Const::LOG_RESPONSE_BLANK, :msg => '无法获取日志信息，请检查页数', :total_num => @logs_count[0].count, :num_per_page => Const::LOG_NUM, :log_list => nil }
      else
        render :json => { :status => Const::LOG_RESPONSE_SUCCESS, :msg => '获取成功', :total_num => @logs_count[0].count, :num_per_page => Const::LOG_NUM, :log_list => @logs }
      end
    end
  end


end
