class AddCountryToHappenings < ActiveRecord::Migration
  def change
    add_column :happenings, :country, :string
  end
end
