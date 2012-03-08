class CreateWords < ActiveRecord::Migration
	def change
		create_table :words do |t|
			  t.string :wordstem, :limit => 20
			  t.integer :should
			  t.integer :should_not
			  t.integer :user_id

			  t.timestamps
		end
		add_index :words, [:user_id, :created_at]
	end
end
