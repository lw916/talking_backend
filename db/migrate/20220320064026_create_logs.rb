class CreateLogs < ActiveRecord::Migration[6.1]
  def change
    create_table :logs do |t|
      t.column :roles, 'varchar(255)' # 操作用户职能
      t.column :username, 'varchar(255)' # 用户名
      t.column :ip_addr, 'varchar(255)' # 操作用户ip
      t.column :action_type, 'text' # 日志内容
      t.column :created_user, 'varchar(255)' # 创建用户
      t.column :updated_user, 'varchar(255)' # 更新用户
      t.timestamps
    end
  end
end
