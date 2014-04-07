class AddDistanceToTracks < ActiveRecord::Migration
  def change
    add_column :tracks, :distance, :integer
  end
end
