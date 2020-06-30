class CreateUsers < ActiveRecord::Migration[5.1]
  def up
    create_table :users do |t|
      t.string :name, null: false
      t.decimal :balance, precision: 16, scale: 2, default: 0.0

      t.timestamps
    end
  end

  def down
    drop_table :users
  end
end
