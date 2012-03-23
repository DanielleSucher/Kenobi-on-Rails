class ChangeWordstemsToBinaryOnUser < ActiveRecord::Migration
  def up
  	remove_column :users, :wordstems
  	add_column :users, :wordstems, :binary, :limit => nil
  end

  def down
  	remove_column :users, :wordstems
  	add_column :users, :wordstems, :text, :limit => nil
  end
end
