class Notify < ApplicationRecord

  # 获取修改提醒列表
  def return_change_list(timestamp)
    find_by_sql(sql= "select * from notifies where created_at >= #{timestamp}");
  end

  # 定期删除提醒列表函数

end
