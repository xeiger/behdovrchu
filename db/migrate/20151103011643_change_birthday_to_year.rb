class ChangeBirthdayToYear < ActiveRecord::Migration
  def change
    add_column :entrants, :year, :integer

    Entrant.update_all("year = date_part('year', birthday)")

    change_column :entrants, :year, :integer, null: false
    remove_column :entrants, :birthday
  end
end
