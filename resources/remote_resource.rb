resource_name :remote_resource
provides :remote_resource

default_action :create

property :remote_resource_name, String, name_property: true
property :path, String
property :source, String, required: true

action_class do
end

action :create do
  cache_path = ::File.join(Config[:file_cache_path], 'remote_resource')
  ::FileUtils.mkdir_p cache_path
  path = new_resource.path || new_resource.remote_resource_name
  res_context = ::RemoteResource::Context.new(
      new_resource.source,
      path,
      cache_path,
      run_context
  )
  did_download = ::RemoteResource::Helper.download(res_context)
  new_resource.updated_by_last_action(did_download)
end