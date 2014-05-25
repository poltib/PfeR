class CreateTracks < ActiveRecord::Migration
  def change
    create_table :tracks do |t|
      t.belongs_to :user
      t.belongs_to :group
      t.string :name
      t.string :slug
      t.text :description
      t.text :polyline
      t.integer :location
      t.belongs_to :happening
      t.string :route
      t.string :length
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
  end
end
