json.array!(@movies) do |movie|
  json.extract! movie, :id, :movie_name, :movie_file, :ready_to_watch
  json.url movie_url(movie, format: :json)
end
