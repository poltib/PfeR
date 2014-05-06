class RemoveCulomnsFromHappening < ActiveRecord::Migration
  def change
  	remove_column :happenings, :city
  	remove_column :happenings, :postalCode
  	remove_column :happenings, :country
  end
end
