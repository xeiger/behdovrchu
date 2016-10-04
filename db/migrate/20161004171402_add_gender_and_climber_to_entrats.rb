class AddGenderAndClimberToEntrats < ActiveRecord::Migration
  def change
    remove_column :entrants, :gender

    add_column :entrants, :male, :boolean, default: true
    add_column :entrants, :climber, :boolean, default: false
  end
end
