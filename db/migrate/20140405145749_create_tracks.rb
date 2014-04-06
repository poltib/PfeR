class CreateTracks < ActiveRecord::Migration
  def change
    create_table :tracks do |t|
      t.string :name
      t.belongs_to :happening

      t.timestamps
    end
  end
end
