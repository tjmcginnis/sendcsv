class CreateIngestions < ActiveRecord::Migration[8.1]
  def change
    create_table :ingestions do |t|
      t.string :public_id, null: false, limit: 12
      t.integer :status, null: false, limit: 1, default: 0
      t.string :error_message, default: nil
      t.references :table, null: false, foreign_key: true

      t.timestamps
    end
  end
end
