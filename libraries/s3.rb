module RemoteResource
  class S3RemoteResource
    attr_accessor :bucket_name, :object_name, :s3_endpoint, :dlcheck_source
    class InvalidS3SourceURL < StandardError
    end

    def prepare(context)
      source = context.source
      scheme_part, host_part, path_part = ::URI.split(source).compact
      if scheme_part != 's3'
        raise InvalidS3SourceURL
      end
      @bucket_name = host_part
      @s3_endpoint = 's3.amazonaws.com'
      @object_name = path_part.gsub(/^\//, '')
      @dlcheck_source = "s3://#{@s3_endpoint}/#{@bucket_name}/#{@object_name}"
      @cache_path = context.cache_path
      context.install_gem 'aws-sdk-s3', '1.60.1'
      self
    end

    def download(context)
      self.prepare(context)
      object = s3_object(@bucket_name, @object_name)
      object_last_modified_hash = create_dlcheck_from_object object
      remote_changed = read_cached_dlcheck != object_last_modified_hash
      context.extract_metadata.each do |key, path|
        context.write_value_to_file path, get_metadata_from_object(object, key.to_s)
      end
      if !context.is_present_in_cache? || remote_changed
        write_object object, context.cached_file
        write_dlcheck object_last_modified_hash
      end
      if !context.is_present? || remote_changed
        context.copy_from_cache
        true
      else
        false
      end
    end

    def s3_object(bucket_name, object_name)
      require 'aws-sdk-s3'
      Aws::S3::Object.new(bucket_name: bucket_name,
                          key: object_name)
    end

    def create_dlcheck_from_object(object)
      Digest::MD5.hexdigest(object.data.last_modified.to_s)
    end

    def cached_dlcheck
      scrubbed_uri = @dlcheck_source.gsub(/\W/, '_')[0..63]
      uri_md5 = Digest::MD5.hexdigest(@dlcheck_source)
      ::File.join(@cache_path, "#{scrubbed_uri}-#{uri_md5}")
    end

    def read_cached_dlcheck
      return '' unless ::File.exists?(cached_dlcheck)
      ::File.read(cached_dlcheck).strip
    end

    def write_dlcheck(dlcheck_data)
      ::File.open(cached_dlcheck, 'w') { |file| file.puts dlcheck_data }
    end

    def get_metadata_from_object(object, key)
      object.data.metadata[key].to_s
    end

    def write_object(object, path)
      object.download_file path
    end
  end
end