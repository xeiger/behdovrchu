class DestroyAllEntrants < ActiveRecord::Migration
  def change
    Entrant.destroy_all
  end
end
