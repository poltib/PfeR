class ChangeColumnsLatlngToTracks < ActiveRecord::Migration
  def self.up
    connection.execute(%q{
        alter table tracks
        alter column latitude
        type float using latitude::float
    })
    connection.execute(%q{
        alter table tracks
        alter column longitude
        type float using longitude::float
    })
  end
end
