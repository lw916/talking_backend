class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.column :username, 'varchar(20)', :null => false
      t.column :password, 'varchar(40)', :null => false
      t.column :email, 'varchar(20)', :null => false
      t.column :avatar, 'text'
      t.column :status, 'int(0)', :null => false
      t.timestamps
    end
  end
end
