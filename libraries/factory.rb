require_relative './s3'
require_relative './http'
module RemoteResource
  class Factory
    class UnsupportedScheme < StandardError
    end
    def create(source)
      uri = ::URI.parse(source)
      case uri.scheme
      when /^http/ then
        RemoteResource::HttpRemoteResource.new
      when 's3'
        RemoteResource::S3RemoteResource.new
      else
        raise UnsupportedScheme
      end
    end
  end
end