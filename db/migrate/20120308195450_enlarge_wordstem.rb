class EnlargeWordstem < ActiveRecord::Migration
  def up
  	change_column :words, :wordstem, :string, :limit => nil
  end

  def down
  	change_column :words, :wordstem, :string, :limit => 20
  end
end
