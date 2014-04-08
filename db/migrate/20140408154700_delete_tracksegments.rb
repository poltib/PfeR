class DeleteTracksegments < ActiveRecord::Migration
  def change
  	drop_table(:tracksegments)
  end
end
