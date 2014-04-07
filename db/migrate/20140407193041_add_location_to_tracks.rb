class AddLocationToTracks < ActiveRecord::Migration
  def change
    add_column :tracks, :location, :integer
  end
end
