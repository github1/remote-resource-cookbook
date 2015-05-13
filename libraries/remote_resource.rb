class Chef
  module RemoteResource
    
    class UnsupportedRemoteResourceScheme < StandardError; end
    
    def self.resource_for(source, path, cache_path, run_context)
      uri = ::URI.parse(source)
      if uri.scheme == "s3"
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
      include Chef::RemoteResource

      def initialize(source, path, cache_path)
        protocol, s3_endpoint, bucket_and_object = ::URI.split(source).compact
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
        AWS.config(:s3 => { :endpoint => @s3_endpoint })
        object = get_s3_object(@bucket_name, @object_name)
        object_checksum = Digest::MD5.hexdigest(object.last_modified.to_s)
        unless ::File.exists?(@path) && read_cached_checksum == object_checksum
          ::File.open(@path, 'wb') do |file|
            object.read do |chunk|
              file.write(chunk)
            end
          end
          write_checksum object_checksum
          return true
        end
        return false
      end

      def required_gems
        { "aws-sdk" => "1.29.0"}
      end

      def get_s3_object(bucket_name, object_name)
        s3_client = AWS::S3.new()
        bucket = s3_client.buckets[bucket_name]
        raise S3BucketNotFoundError.new(bucket_name) unless bucket.exists?
        object = bucket.objects[object_name]
        raise S3ArtifactNotFoundError.new(bucket_name, object_name) unless object.exists?
        object
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
        ::File.open(cached_checksum, "w") { |file| file.puts checksum }
      end

    end
    
    class HTTPResource
      include Chef::RemoteResource
      
      def initialize(source, path, run_context)
        @source = source
        @path = path
        @run_context = run_context
      end

      def download
        f =  Chef::Resource::File::RemoteFile.new(@path, @run_context)
        f.source @source
        f.run_action :create_if_missing
        f.updated_by_last_action?
      end
    
    end
  end
end

class Chef
  class Resource::RemoteResource < Resource::LWRPBase
    identity_attr :path
    provides :remote_resource
    self.resource_name = :remote_resource
    actions :create
    default_action :create
    attribute :path,
      kind_of: String,
      name_attribute: true
    attribute :source,
      kind_of: String,
      required: true
  end
end

class Chef
  class Provider::RemoteResource < Provider::LWRPBase
    require 'chef/mixin/create_path'
    include Chef::Mixin::CreatePath
    use_inline_resources

    attr_reader :remote_resource_inst
    
    def load_current_resource
      cache_path = ::File.join(Chef::Config[:file_cache_path], 'remote_resource')
      create_path cache_path
      @remote_resource_inst = Chef::RemoteResource.resource_for(new_resource.source, new_resource.path, cache_path, run_context)
      unless @remote_resource_inst.required_gems.empty?
        unless Chef::Platform.windows?
          case node['platform_family']
          when 'debian'
            nokogiri_requirements = %W{gcc make libxml2 libxslt1.1 libxml2-dev libxslt1-dev}
          when 'rhel'
            nokogiri_requirements = %W{gcc make libxml2 libxslt libxml2-devel libxslt-devel patch}
          else
            Chef::Log.warn "Watch out, you might not be able to install the nokogiri gem!"
          end
          nokogiri_requirements.each do |nokogiri_requirement|
            package nokogiri_requirement do
              action :nothing
            end.run_action(:install)
          end
        end
      end
      @remote_resource_inst.required_gems.each do |name, version|
        c = chef_gem name do
          version version
        end
        c.compile_time(true) if c.respond_to?(:compile_time)
      end
    end

    action(:create) do
      new_resource.updated_by_last_action(remote_resource_inst.download)
    end

  end
end

Chef::Platform.set(
  resource: :remote_resource,
  provider: Chef::Provider::RemoteResource
)