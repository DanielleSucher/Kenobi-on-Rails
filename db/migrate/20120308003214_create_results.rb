class CreateResults < ActiveRecord::Migration
  def change
    create_table :results do |t|
      t.text :url, :limit => nil
      t.integer :user_id

      t.timestamps
    end
    add_index :results, [:user_id, :created_at]
  end
end
