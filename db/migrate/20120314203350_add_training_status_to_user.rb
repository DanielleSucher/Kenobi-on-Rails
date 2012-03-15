class AddTrainingStatusToUser < ActiveRecord::Migration
  def change
  	add_column :users, :training_status, :string, :limit => nil
  end
end
