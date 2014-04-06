class AddRouteToTracks < ActiveRecord::Migration
  def change
    add_column :tracks, :route, :string
  end
end
