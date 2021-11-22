class CreateChannelUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :channel_users do |t|
      t.column :channel_id, "int(64)"
      t.column :user_id, "int(64)"
      t.column :username, "varchar(40)"
      t.timestamps
    end
  end
end
