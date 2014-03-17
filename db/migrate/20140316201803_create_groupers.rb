class CreateGroupers < ActiveRecord::Migration
  def change
    create_table :groupers do |t|
      t.belongs_to :user
      t.belongs_to :group

      t.timestamps
    end
  end
end
