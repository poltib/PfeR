class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.attachment :image
      t.belongs_to :user
      t.integer :imagable_id
      t.string :imagable_type
      
      t.timestamps
    end
  end
end
