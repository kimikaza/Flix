class Movie < ActiveRecord::Base

  scope :transcoding, -> {
     where(ready_to_watch: false)
    .where.not(transcode_hls_job_id: ["", nil])
  }


  def create_transcode_job_hls!

    output_bucket.objects(prefix: "#{self.movie_file}/hls/").each do |object_summary| 
      output_bucket.object(object_summary.key).delete
    end    

    transcode_client = Aws::ElasticTranscoder::Client.new(region: AWS_REGION)
    transcode_client.create_job({
      pipeline_id: DEFAULT_PIPELINE,
      output_key_prefix: "#{self.movie_file}/hls/",
      input: {
        key: self.movie_file,
        container: "mp4",
        frame_rate: "auto",
        resolution: "auto",
        aspect_ratio: "auto",
        interlaced: "auto"
      },
      outputs: [
        {
          key: "hls1M",
          thumbnail_pattern: "",
          rotate: "0",
          preset_id: "1351620000001-200035",
          :segment_duration => "10"},
        {
          key: "hls600K",
          thumbnail_pattern: "",
          rotate: "0",
          preset_id: "1351620000001-200045",
          :segment_duration => "10"},
        {
          key: "hls400K",
          thumbnail_pattern: "",
          rotate: "0",
          preset_id: "1351620000001-200055",
          :segment_duration => "10"}
      ],
      playlists: [ {
        :name => "hls_playlist",
        :format => "HLSv3",
        :output_keys => ["hls1M", "hls600K", "hls400K"]
      } ]
    })

  end

  def hls_playlist_url
    "https://"+CLOUD_FRONT_DOMAIN+"/#{movie_file}/hls/hls_playlist.m3u8"
  end

  #private 


  #s3 client
  def get_s3_client
    Aws::S3::Resource.new(region: AWS_REGION)
  end

  #get input bucket
  def output_bucket
    client = get_s3_client
    buckets = client.buckets.select do |bucket| 
      bucket.name==OUTPUT_BUCKET
    end
    buckets.first
  end

end
