class CreateJoinTableCategoryForum < ActiveRecord::Migration
  def change
    create_join_table :categories, :forums do |t|
      # t.index [:category_id, :form_id]
      # t.index [:form_id, :category_id]
    end
  end
end
