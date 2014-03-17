class CreateAnnounces < ActiveRecord::Migration
  def change
    create_table :announces do |t|
      t.text :announce
      t.belongs_to :user

      t.timestamps
    end
  end
end
