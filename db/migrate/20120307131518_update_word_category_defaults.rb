class UpdateWordCategoryDefaults < ActiveRecord::Migration
  def up
  	change_column :words, :should, :integer, :null => false, :default => 0
  	change_column :words, :should_not, :integer, :null => false, :default => 0
  end

  def down
  	change_column :words, :should, :integer
  	change_column :words, :should_not, :integer
  end
end