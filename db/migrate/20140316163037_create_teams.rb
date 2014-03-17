class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.string :name
      t.text :description
      t.string :image
      t.string :thumb
      t.belongs_to :user

      t.timestamps
    end
  end
end
