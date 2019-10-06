require 'uri'
module RemoteResource
  class Context

    @@installed_gems = []

    attr_accessor :source, :path, :cache_path, :run_context, :cached_file, :was_downloaded

    def initialize(source, path, cache_path, run_context)
      @source = source
      @path = path
      @cache_path = cache_path
      @run_context = run_context
      @cached_file = ::File.join(@cache_path, File.basename(URI.parse(source).path))
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