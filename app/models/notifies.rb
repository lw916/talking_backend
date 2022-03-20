class Notifies < ApplicationRecord

  # 获取修改提醒列表
  def self.return_change_list(timestamp)
    Notifies.find_by_sql("select * from notifies where created_at >= '#{Time.at(timestamp)}'");
  end

  # 定期删除提醒列表函数

end
