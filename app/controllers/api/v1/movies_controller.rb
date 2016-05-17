class Api::V1::MoviesController < Api::ApiController

  def index
    @movies = Movie.watchable
  end

end
