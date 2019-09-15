module RemoteResource
  module Helper
    def self.download(context, factory = RemoteResource::Factory.new)
      resource = factory.create(context.source)
      resource.download(context)
    end
  end
end