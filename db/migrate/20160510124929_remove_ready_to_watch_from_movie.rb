class RemoveReadyToWatchFromMovie < ActiveRecord::Migration
  def change
    remove_column :movies, :ready_to_watch
  end
end
