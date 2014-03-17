class CreateConversations < ActiveRecord::Migration
  def change
    create_table :conversations do |t|
      t.belongs_to :message
      t.belongs_to :user

      t.timestamps
    end
  end
end
