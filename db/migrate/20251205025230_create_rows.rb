class CreateRows < ActiveRecord::Migration[8.1]
  def change
    create_table :rows do |t|
      t.string :public_id, null: false, limit: 12
      t.references :table, null: false, foreign_key: true
      t.json :contents, null: false, default: []

      t.timestamps
    end
  end
end
