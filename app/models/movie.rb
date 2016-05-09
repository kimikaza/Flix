class Movie < ActiveRecord::Base


  def create_transcode_job_hls!

    self.bucket.objects.with_prefix("#{self.movie_file}/hls/").each { |o| o.delete }

    transcode_client = AWS::ElasticTranscoder::Client.new
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
          preset_id: "1351620000001-200035",
          :segment_duration => "10"},
        {
          key: "hls400K",
          thumbnail_pattern: "",
          rotate: "0",
          preset_id: "1351620000001-200035",
          :segment_duration => "10"}
      ],
      playlists: [ {
        :name => "hls_playlist",
        :format => "HLSv3",
        :output_keys => hls_transcode_keys
      } ]
    })

  end

  private 

  def bucket

  end

  {
        key: "#{size_info[:file]}",
        thumbnail_pattern: "",
        rotate: "0",
        preset_id: TRANSCODE_PRESETS[size_info[:file]],
        :segment_duration => "10"
      }

end
