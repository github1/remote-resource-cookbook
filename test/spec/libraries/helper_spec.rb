require_relative '../../../libraries/helper.rb'

describe 'RemoteResource::Helper' do
  let(:resource) {
    double('resource')
  }
  let(:context) {
    double('context')
  }
  let(:factory) {
    double('factory')
  }
  describe 'download' do
    before do
      allow(resource)
          .to receive(:download)
                  .with(anything)
                  .and_return(true)
      allow(context)
          .to receive(:source)
                  .and_return('s3://some-bucket/some-object')
      allow(factory)
          .to receive(:create)
                  .with(anything)
                  .and_return(resource)
    end
    it 'downloads the file' do
      expect(
          RemoteResource::Helper::download(context, factory)
      ).to be(true)
      expect(resource)
          .to have_received(:download).with(context)
    end
  end
end