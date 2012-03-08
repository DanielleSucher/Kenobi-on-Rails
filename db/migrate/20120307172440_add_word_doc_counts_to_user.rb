class AddWordDocCountsToUser < ActiveRecord::Migration
  def change
  	add_column :users, :total_words, :integer, :null => false, :default => 0
  	add_column :users, :total_docs, :integer, :null => false, :default => 0
  	add_column :users, :should_words, :integer, :null => false, :default => 0
  	add_column :users, :should_not_words, :integer, :null => false, :default => 0
  	add_column :users, :should_docs, :integer, :null => false, :default => 0
  	add_column :users, :should_not_docs, :integer, :null => false, :default => 0
  end
end
