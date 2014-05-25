class CreateForums < ActiveRecord::Migration
  def change
    create_table :forums do |t|
      t.text :post
      t.string :name
      t.string :slug
      t.belongs_to :user
      t.references :forumable, polymorphic: true

      t.timestamps
    end
  end
end
