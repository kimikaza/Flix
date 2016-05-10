class AddColumnsToMovie < ActiveRecord::Migration
  def change
    add_column :movies, :ready_to_watch, :boolean
    add_column :movies, :transcode_hls_job_id, :string
    add_column :movies, :transcode_error, :boolean
  end
end
