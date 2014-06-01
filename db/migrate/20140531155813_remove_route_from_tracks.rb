class RemoveRouteFromTracks < ActiveRecord::Migration
  def self.up
    change_table :tracks do |t|
      t.remove :route
    end
  end

  def self.down
    change_table :tracks do |t|
      t.string :route
    end
  end
end
