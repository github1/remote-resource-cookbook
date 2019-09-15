require_relative '../../../libraries/context.rb'

describe 'RemoteResource::Context' do
  let(:ctx) {
    RemoteResource::Context
              .new(
                  's3://something',
                  '/some/path/file.txt',
                  '/tmp/cache',
                  nil)
  }
  describe 'is_present' do
    it 'returns true if the file exists' do
      allow(::File).to receive(:exists?).and_return(true)
      expect(ctx.is_present?).to be(true)
    end
    it 'returns false if the file does not exist' do
      expect(ctx.is_present?).to be(false)
    end
  end
end