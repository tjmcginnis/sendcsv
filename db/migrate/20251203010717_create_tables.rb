class CreateTables < ActiveRecord::Migration[8.1]
  def change
    create_table :tables do |t|
      t.string :name, null: false
      t.string :public_id, null: false, limit: 12
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
