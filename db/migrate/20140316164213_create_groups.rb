class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :name
      t.text :description
      t.string :image
      t.string :thumb
      t.belongs_to :user

      t.timestamps
    end
  end
end
