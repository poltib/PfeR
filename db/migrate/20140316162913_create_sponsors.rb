class CreateSponsors < ActiveRecord::Migration
  def change
    create_table :sponsors do |t|
      t.string :name
      t.string :addresse
      t.belongs_to :happening
      t.string :avatar

      t.timestamps
    end
  end
end
