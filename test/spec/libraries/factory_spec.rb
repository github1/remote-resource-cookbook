require_relative '../../../libraries/factory.rb'

describe 'RemoteResource::Factory' do
  let(:factory) {
    RemoteResource::Factory.new
  }
  describe 'create' do
    it 'creates S3 remote resources' do
      expect(factory.create('s3://something'))
          .to be_a(RemoteResource::S3RemoteResource)
    end
    it 'raises error if scheme not supported' do
      expect {
        factory.create('blap://something')
      }.to raise_error RemoteResource::Factory::UnsupportedScheme
    end
  end
end