namespace :flix do
  desc "Update the status of movies transcode progress"
  task :update_status => :environment do
    transcoder = Aws::ElasticTranscoder::Client.new(region: AWS_REGION)
    Movie.transcoding.each do |transcoding_movie|

      res = transcoder.read_job(id: transcoding_movie.transcode_hls_job_id.to_s)

      status = res[:job][:status].downcase

      if (status == "complete")
        transcoding_movie.update_attributes(ready_to_watch: true)
      elsif (status == "error")
        transcoding_movie.update_attributes(transcode_error: true)
      end

    end
  end
end