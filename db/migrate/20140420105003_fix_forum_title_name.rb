class FixForumTitleName < ActiveRecord::Migration
  def change
    change_table :forums do |t|
      t.rename :title, :name
    end
  end
end
