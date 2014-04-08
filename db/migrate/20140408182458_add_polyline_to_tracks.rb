class AddPolylineToTracks < ActiveRecord::Migration
  def change
    add_column :tracks, :polyline, :text
  end
end
