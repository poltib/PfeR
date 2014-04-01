class AddRoutegpxToHappenings < ActiveRecord::Migration
  def change
    add_column :happenings, :routegpx, :string
  end
end
