class AddAttachmentAvatarToSponsors < ActiveRecord::Migration
  def self.up
    change_table :sponsors do |t|
      t.attachment :avatar
    end
  end

  def self.down
    drop_attached_file :sponsors, :avatar
  end
end
