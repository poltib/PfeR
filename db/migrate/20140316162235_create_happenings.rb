class CreateHappenings < ActiveRecord::Migration
  def change
    create_table :happenings do |t|
      t.string :name
      t.text :description
      t.string :address
      t.string :link
      t.timestamp :date
      t.belongs_to :user
      t.belongs_to :event_type

      t.timestamps
    end
  end
end
