class Chef
  class Resource::RemoteResource < Resource
    require 'chef/mixin/create_path'
    include Mixin::CreatePath

    resource_name :remote_resource

    default_action :create

    property :remote_resource_name, String, name_property: true
    property :path, String
    property :source, String, required: true

    action :create do
      cache_path = ::File.join(Config[:file_cache_path], 'remote_resource')
      create_path cache_path
      path = new_resource.path || new_resource.remote_resource_name
      did_download = ::RemoteResource::Helper.download(
          ::RemoteResource::Context.new(
              new_resource.source,
              path,
              cache_path,
              run_context
          )
      )
      new_resource.updated_by_last_action(did_download)
    end

  end
end