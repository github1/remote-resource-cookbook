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
      @s3_endpoint = 's3.amazon.com'
      @object_name = path_part.gsub(/^\//, '')
      @dlcheck_source = "s3://#{@s3_endpoint}/#{@bucket_name}/#{@object_name}"
      @cache_path = context.cache_path
      context.install_gem 'aws-sdk', '3.0.1'
      self
    end

    def download(context)
      self.prepare(context)
      object = s3_client.get_object(bucket: @bucket_name, key: @object_name)
      object_last_modified_hash = create_dlcheck_from_object object
      if !context.is_present? || read_cached_dlcheck != object_last_modified_hash
        write_object @bucket_name, @object_name, context.path
        write_dlcheck object_last_modified_hash
        true
      else
        false
      end
    end

    def s3_client
      require 'aws-sdk'
      Aws::S3::Client.new
    end

    def create_dlcheck_from_object(object)
      Digest::MD5.hexdigest(object.last_modified.to_s)
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

    def write_object(bucket_name, object_name, path)
      ::File.open(path, 'wb') do |file|
        s3_client.get_object(bucket: bucket_name, key: object_name) do |chunk|
          file.write(chunk)
        end
      end
    end
  end
end