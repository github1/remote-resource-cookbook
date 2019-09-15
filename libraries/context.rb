module RemoteResource
  class Context
    attr_accessor :source, :path, :cache_path, :run_context
    def initialize(source, path, cache_path, run_context)
      @source = source
      @path = path
      @cache_path = cache_path
      @run_context = run_context
    end
    def is_present?
      ::File.exists?(@path)
    end
    def install_gem(name, version)
      f = ::Chef::Resource::ChefGem.new(name, @run_context)
      f.version version
      f.run_action :install
      f.updated_by_last_action?
    end
  end
end