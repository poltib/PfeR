class FixCategoriesFormsTableName < ActiveRecord::Migration
  def change
    rename_table :categories_forms, :categories_forums
  end
end
