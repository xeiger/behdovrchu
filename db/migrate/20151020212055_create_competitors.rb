class CreateCompetitors < ActiveRecord::Migration
  def change
    create_table :competitors do |t|
      t.string :first_name, null: false

      t.timestamps null: false
    end
  end
end
