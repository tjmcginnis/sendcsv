class AddHeaderToTables < ActiveRecord::Migration[8.1]
  def change
    add_column :tables, :header, :json, null: false, default: []
  end
end
