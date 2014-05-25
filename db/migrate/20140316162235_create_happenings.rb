class CreateHappenings < ActiveRecord::Migration
  def change
    create_table :happenings do |t|
      t.string :name
      t.text :description
      t.string :slug
      t.string :address
      t.string :link
      t.timestamp :date
      t.float :latitude
      t.float :longitude
      t.belongs_to :user
      t.belongs_to :event_type
      t.belongs_to :group

      t.timestamps
    end
  end
end
