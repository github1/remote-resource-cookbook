module RemoteResource
  class HttpRemoteResource
    def download(context)
      f = ::Chef::Resource::File::RemoteFile.new(context.path, context.run_context)
      f.source context.source
      f.run_action :create_if_missing
      f.updated_by_last_action?
    end
  end
end