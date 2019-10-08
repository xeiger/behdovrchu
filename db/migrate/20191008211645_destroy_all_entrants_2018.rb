class DestroyAllEntrants2018 < ActiveRecord::Migration
  def change
		Entrant.destroy_all
  end
end
