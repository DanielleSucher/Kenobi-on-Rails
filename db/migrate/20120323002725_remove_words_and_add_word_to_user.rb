class RemoveWordsAndAddWordToUser < ActiveRecord::Migration
  def up
  	add_column :users, :wordstems, :text, :limit => nil
  	drop_table :words
  end

  def down
  end
end
