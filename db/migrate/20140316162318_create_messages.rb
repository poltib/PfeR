class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :object
      t.text :message
      t.belongs_to :user

      t.timestamps
    end
  end
end
