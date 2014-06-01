class CreateXmlAttachements < ActiveRecord::Migration
  def change
    create_table :xml_attachements do |t|
      t.string :uploaded_file
      t.belongs_to :track
      t.timestamps
    end
  end
end
