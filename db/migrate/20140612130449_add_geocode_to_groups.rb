class AddGeocodeToGroups < ActiveRecord::Migration
  def self.up
    change_table :groups do |t|
      t.string :address
      t.float :latitude
      t.float :longitude
    end
  end

  def self.down
    change_table :groups do |t|
      t.remove :address
      t.remove :latitude
      t.remove :longitude
    end
  end
end
