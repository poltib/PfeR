class CreateSponsors < ActiveRecord::Migration
  def change
    create_table :sponsors do |t|
      t.string :name
      t.string :image
      t.string :thumb
      t.string :addresse
      t.belongs_to :happening

      t.timestamps
    end
  end
end
