class CreateEntrants < ActiveRecord::Migration
  def change
    create_table :entrants do |t|

      t.string :first_name, null: false
      t.string :surname, null: false
      t.date :birthday, null: false
      t.string :club
      t.string :address
      t.string :email, null: false
      t.boolean :paid, null: false, default: false
      t.string :variable_symbol, null: false

      t.boolean :archived, null: false, default: false

      t.timestamps null: false
    end

    add_index :entrants, :variable_symbol, unique: true
  end
end
