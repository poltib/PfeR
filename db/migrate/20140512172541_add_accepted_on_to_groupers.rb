class AddAcceptedOnToGroupers < ActiveRecord::Migration
  def change
    add_column :groupers, :accepted_on, :timestamp
  end
end
