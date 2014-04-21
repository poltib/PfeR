class DeleteCategoriesForms < ActiveRecord::Migration
  def change
  	drop_table(:categories_forms)
  end
end
