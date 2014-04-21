class AddAttachmentImageToImages < ActiveRecord::Migration
  def self.up
    change_table :images do |t|
      t.attachment :image
      t.belongs_to :user
      t.integer :imagable_id
      t.string :imagable_type
    end
  end

  def self.down
    drop_attached_file :images, :image
  end
end
