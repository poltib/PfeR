class AddRouteToHappenings < ActiveRecord::Migration
  def change
    add_column :happenings, :route, :string
  end
end
