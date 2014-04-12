class AddLongitudeToTracks < ActiveRecord::Migration
  def change
    add_column :tracks, :longitude, :string
  end
end
