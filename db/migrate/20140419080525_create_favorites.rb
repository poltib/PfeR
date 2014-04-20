class CreateFavorites < ActiveRecord::Migration
  def change
    create_table :favorites do |t|
      t.belongs_to :user
      t.integer :favoritable_id
      t.string :favoritable_type

      t.timestamps
    end
  end
end
