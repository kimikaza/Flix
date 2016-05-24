json.movies @movies do |movie|
  json.movie_file movie.movie_file
  json.movie_name movie.movie_name
  json.hls_playlist_url movie.hls_playlist_url
end