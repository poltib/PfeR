class ChangeDistanceToTracks < ActiveRecord::Migration
  def change
  	change_table :tracks do |t|
      t.rename :distance, :length
    end
  end
end
