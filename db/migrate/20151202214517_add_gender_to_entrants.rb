class AddGenderToEntrants < ActiveRecord::Migration
  def change
    add_column :entrants, :gender, :string
  end
end
