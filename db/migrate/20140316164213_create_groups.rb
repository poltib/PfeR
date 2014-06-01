class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :name
      t.text :description
      t.belongs_to :user
      t.boolean :team
      t.string :avatar

      t.timestamps
    end
  end
end
