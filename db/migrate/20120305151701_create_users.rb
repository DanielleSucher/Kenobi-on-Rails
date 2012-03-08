class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :askme_id, :limit => 20

      t.timestamps
    end
  end
end
