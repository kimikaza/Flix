class CreateMovies < ActiveRecord::Migration
  def change
    create_table :movies do |t|
      t.string :movie_name
      t.string :movie_file
      t.string :ready_to_watch

      t.timestamps null: false
    end
  end
end
