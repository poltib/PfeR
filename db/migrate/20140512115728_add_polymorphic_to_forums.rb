class AddPolymorphicToForums < ActiveRecord::Migration
  def change
  	add_column :forums, :forumable_id, :integer
    add_column :forums, :forumable_type, :string
  end
end