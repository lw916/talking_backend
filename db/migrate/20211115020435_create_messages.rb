class CreateMessages < ActiveRecord::Migration[6.1]
  def change
    create_table :messages do |t|
      # 归属频道id
      t.references :channel, foreign_key:true
      # 对讲内容
      t.text :message,:limit => 16.megabytes - 1
      # 消息状态
      t.boolean :status
      # 语音信息用户来源
      t.column :username, 'varchar(20)'
      # 创建时间/修改时间时间戳
      t.timestamps
    end
    add_index :messages, :id, unique: true
  end
end
