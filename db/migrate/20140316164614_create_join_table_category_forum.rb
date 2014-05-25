class CreateJoinTableCategoryForum < ActiveRecord::Migration
  def change
    create_join_table :categories, :forums do |t|
      t.index [:category_id, :forum_id]
      t.index [:forum_id, :category_id]
    end
  end
end
