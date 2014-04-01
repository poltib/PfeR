class AddRoutekmlToHappenings < ActiveRecord::Migration
  def change
    add_column :happenings, :routekml, :string
  end
end
