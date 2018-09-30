class DestroyAllEntrants2017 < ActiveRecord::Migration
  def change
  	Entrant.destroy_all
  end
end
