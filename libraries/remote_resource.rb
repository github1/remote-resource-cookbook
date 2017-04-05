class Chef
  module RemoteResource

    class UnsupportedRemoteResourceScheme < StandardError; end

    def self.resource_for(source, path, cache_path, run_context)
      uri = ::URI.parse(source)
      if uri.scheme == 's3'
        return S3Resource.new(source, path, cache_path)
      elsif uri.scheme =~ /^http/
        return HTTPResource.new(source, path, run_context)
      end
      raise UnsupportedRemoteResourceScheme
    end

    def download
    end

    def required_gems
      Hash.new
    end

    class S3Resource
      include RemoteResource

      def initialize(source, path, cache_path)
        scheme, s3_endpoint, bucket_and_object = ::URI.split(source).compact
        path_parts = bucket_and_object[1..-1].split('/')
        bucket_name = path_parts[0]
        object_name = path_parts[1..-1].join('/')
        @source = source
        @s3_endpoint = s3_endpoint
        @bucket_name = bucket_name
        @object_name = object_name
        @path = path
        @cache_path = cache_path
      end

      def download
        require 'aws-sdk'
        s3_client = Aws::S3::Client.new
        object = s3_client.get_object(bucket: @bucket_name, key: @object_name)
        object_checksum = Digest::MD5.hexdigest(object.last_modified.to_s)
        if !::File.exists?(@path) || read_cached_checksum != object_checksum
          ::File.open(@path, 'wb') do |file|
            s3_client.get_object(bucket: @bucket_name, key: @object_name) do |chunk|
              file.write(chunk)
            end
          end
          write_checksum object_checksum
          return true
        end
        return false
      end

      def required_gems
        {'aws-sdk' => '2.9.3'}
      end

      def cached_checksum
        scrubbed_uri = @source.gsub(/\W/, '_')[0..63]
        uri_md5 = Digest::MD5.hexdigest(@source)
        ::File.join(@cache_path, "#{scrubbed_uri}-#{uri_md5}")
      end

      def cached_checksum_exists?
        ::File.exists?(cached_checksum)
      end

      def read_cached_checksum
        return '' unless cached_checksum_exists?
        ::File.read(cached_checksum).strip
      end

      def write_checksum(checksum)
        ::File.open(cached_checksum, 'w') { |file| file.puts checksum }
      end

    end

    class HTTPResource
      include RemoteResource

      def initialize(source, path, run_context)
        @source = source
        @path = path
        @run_context = run_context
      end

      def download
        f = Resource::File::RemoteFile.new(@path, @run_context)
        f.source @source
        f.run_action :create_if_missing
        f.updated_by_last_action?
      end

    end
  end
end