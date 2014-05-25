class CreateGroupers < ActiveRecord::Migration
  def change
    create_table :groupers do |t|
      t.belongs_to :user
      t.belongs_to :group
      t.timestamp :accepted_on

      t.timestamps
    end
  end
end
