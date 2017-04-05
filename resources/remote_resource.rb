class Chef
  class Resource::RemoteResource < Resource
    require 'chef/mixin/create_path'
    include Mixin::CreatePath

    resource_name :remote_resource

    default_action :create

    property :name, kind_of: String, name_attribute: true
    property :path, kind_of: String
    property :source, kind_of: String, required: true

    action :create do
      cache_path = ::File.join(Config[:file_cache_path], 'remote_resource')
      create_path cache_path
      path = new_resource.path || new_resource.name
      remote_resource_inst = RemoteResource.resource_for(new_resource.source, path, cache_path, run_context)
      remote_resource_inst.required_gems.each do |name, version|
        chef_gem name do
          version version
          compile_time true if Resource::ChefGem.method_defined?(:compile_time)
        end
      end
      new_resource.updated_by_last_action(remote_resource_inst.download)
    end

  end
end