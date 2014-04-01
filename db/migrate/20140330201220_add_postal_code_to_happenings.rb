class AddPostalCodeToHappenings < ActiveRecord::Migration
  def change
    add_column :happenings, :postalCode, :integer
  end
end
