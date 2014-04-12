class AddLatitudeToTracks < ActiveRecord::Migration
  def change
    add_column :tracks, :latitude, :string
  end
end
