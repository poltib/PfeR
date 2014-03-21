class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.text :comment
      t.belongs_to :forum
      t.belongs_to :user

      t.timestamps
    end
  end
end
