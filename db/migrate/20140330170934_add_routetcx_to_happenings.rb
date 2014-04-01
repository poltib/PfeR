class AddRoutetcxToHappenings < ActiveRecord::Migration
  def change
    add_column :happenings, :routetcx, :string
  end
end
