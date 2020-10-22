require 'uri'
module RemoteResource
  class Context

    @@installed_gems = []

    attr_accessor :source, :path, :extract_metadata, :cache_path, :run_context, :cached_file, :was_downloaded

    def initialize(source, path, extract_metadata, cache_path, run_context, unique_cache_file_name = false)
      @source = source
      @path = path
      @extract_metadata = extract_metadata
      @cache_path = cache_path
      @run_context = run_context
      cached_file_suffix = unique_cache_file_name ? "-#{Digest::MD5.base64digest(source).gsub(/[^a-z0-9]+/i, '-')}" : ""
      @cached_file = ::File.join(@cache_path, "#{File.basename(URI.parse(source).path)}#{cached_file_suffix}")
    end

    def is_present?
      ::File.exists?(@path)
    end

    def is_present_in_cache?
      ::File.exists?(@cached_file)
    end

    def copy_from_cache
      ::FileUtils.mkdir_p(::File.dirname @path)
      ::FileUtils.copy_file(@cached_file, @path)
    end

    def write_value_to_file(path, value)
      ::FileUtils.mkdir_p(::File.dirname @path)
      ::File.write(path, value)
    end

    def install_gem(name, version)
      gem_key = "#{name}:#{version}"
      unless @@installed_gems.include? gem_key
        @@installed_gems << gem_key
        f = ::Chef::Resource::ChefGem.new(name, @run_context)
        f.version version
        f.run_action :install
        f.updated_by_last_action?
      end
    end
  end
end