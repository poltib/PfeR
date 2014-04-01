class AddCityToHappenings < ActiveRecord::Migration
  def change
    add_column :happenings, :city, :string
  end
end
