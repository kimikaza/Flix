class MoviesController < ApplicationController

  before_action :set_movie, except: [:index, :new, :create]

  before_action :authenticate_user!

  # GET /movies
  # GET /movies.json
  def index
    @movies = Movie.all
  end

  # GET /movies/1
  # GET /movies/1.json
  def show
  end

  # GET /movies/new
  def new
    @movie = Movie.new
  end

  # GET /movies/1/edit
  def edit
  end

  # POST /movies
  # POST /movies.json
  def create
    @movie = Movie.new(movie_params)

    respond_to do |format|
      if @movie.save
        format.html { redirect_to upload_movie_file_movie_path(@movie), notice: 'Movie was successfully created. Please upload movie file' }
        format.json { render :show, status: :created, location: @movie }
      else
        format.html { render :new }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /movies/1
  # PATCH/PUT /movies/1.json
  def update
    respond_to do |format|
      if @movie.update(movie_params)
        format.html { redirect_to @movie, notice: 'Movie was successfully updated.' }
        format.json { render :show, status: :ok, location: @movie }
      else
        format.html { render :edit }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /movies/1
  # DELETE /movies/1.json
  def destroy
    s3_object = get_movie_object_on_s3
    s3_object.delete unless s3_object.blank?
    @movie.destroy
    respond_to do |format|
      format.html { redirect_to movies_url, notice: 'Movie was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  #create presigned post object and use ti to upload directly to S3
  def upload_movie_file
    bucket = get_input_bucket
    @presigned_post = bucket.presigned_post({
      key: @movie.movie_file,
      success_action_status: "201",
      success_action_redirect: request.base_url + finish_upload_movie_path(@movie),
      content_type: "video/mp4"
    })
    puts @presigned_post.fields
  end

  #when upload finishes, create transcode job in AWS Elastic Transcoder
  def finish_upload
    res = @movie.create_transcode_job_hls!

    if res.error
      flash[:error] = "There was an error creating the transcode job for this movie."
    else
      @movie.update_attributes(ready_to_watch: false, transcode_error: false, transcode_hls_job_id: res.data[:job][:id])
      flash[:success] = "The transcode job was started successfully, your video will be ready when it's finished."
    end

    redirect_to admin_movie_path(@movie)
  end

  def watch

  end

  private

    #s3 client
    def get_s3_client
      Aws::S3::Resource.new(region: AWS_REGION)
    end

    #get input bucket
    def get_input_bucket
      client = get_s3_client
      buckets = client.buckets.select do |bucket| 
        bucket.name==INPUT_BUCKET
      end
      buckets.first
    end

    def get_movie_object_on_s3
      bucket = get_input_bucket
      bucket.objects.first
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_movie
      @movie = Movie.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def movie_params
      params.require(:movie).permit(:movie_name, :movie_file, :ready_to_watch)
    end
end
