class AddCoordsToHappening < ActiveRecord::Migration
  def change
    add_column :happenings, :latitude, :float
    add_column :happenings, :longitude, :float
  end
end
