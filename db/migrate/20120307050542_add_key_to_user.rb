class AddKeyToUser < ActiveRecord::Migration
  def change
  	add_index :users, [:askme_id]
  end
end
