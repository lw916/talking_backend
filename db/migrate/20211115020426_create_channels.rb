class CreateChannels < ActiveRecord::Migration[6.1]
  def change
    create_table :channels do |t|
      # 频道名
      t.string :channel_name
      # 最长可通话时间
      t.integer :maximum_talk
      # 频道状态
      t.boolean :status
      # 创建频道信息用户
      t.column :created_user, 'varchar(40)'
      # 更新频道信息用户
      t.column :updated_user, 'varchar(40)'
      # 创建时间/修改时间时间戳
      t.timestamps
    end
    add_index :channels, :channel_name
  end
end
