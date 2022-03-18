class CreateNotifies < ActiveRecord::Migration[6.1]
  def change
    create_table :notifies do |t|
      t.column :user_id, "bigint" # 修改者用户id
      t.column :type, "string" # 修改内容，格式为json[map]
      t.column :content, 'text' # 修改模块，格式为json[list]
      t.timestamps
    end
  end
end
