class AddContentToResults < ActiveRecord::Migration
  def change
  	add_column :results, :content, :text, :limit => nil
  end
end
