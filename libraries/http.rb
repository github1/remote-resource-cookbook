module RemoteResource
  class HttpRemoteResource
    def download(context)
      f = ::Chef::Resource::File::RemoteFile.new(context.cached_file, context.run_context)
      f.source context.source
      f.run_action :create_if_missing
      if f.updated_by_last_action? || !context.is_present?
        context.copy_from_cache
        true
      else
        false
      end
    end
  end
end