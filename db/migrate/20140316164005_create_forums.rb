class CreateForums < ActiveRecord::Migration
  def change
    create_table :forums do |t|
      t.text :post
      t.string :title
      t.belongs_to :user

      t.timestamps
    end
  end
end
