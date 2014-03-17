class CreateUserStatuses < ActiveRecord::Migration
  def change
    create_table :user_statuses do |t|
      t.belongs_to :user
      t.belongs_to :happening
      t.belongs_to :status

      t.timestamps
    end
  end
end
