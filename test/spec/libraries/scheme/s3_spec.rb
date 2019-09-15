require_relative '../../../../libraries/scheme/s3.rb'

describe 'RemoteResource::S3RemoteResource' do
  let(:context) {
    c = double('context')
    allow(c)
        .to receive(:install_gem).and_return(true)
    c
  }
  let(:res) {
    RemoteResource::S3RemoteResource
        .new
  }
  let(:s3_client) {
    double('s3_client')
  }
  let(:s3_object) {
    double('s3_object')
  }
  describe 'prepare' do
    it 'validates the scheme' do
      allow(context)
          .to receive(:source).and_return('ftp://something')
      expect {
        res.prepare(context)
      }.to raise_error RemoteResource::S3RemoteResource::InvalidS3SourceURL
    end
    it 'parses the source url' do
      allow(context)
          .to receive(:source).and_return('s3://thebucket/theobject')
      res.prepare(context)
      expect(res.bucket_name).to eq 'thebucket'
      expect(res.object_name).to eq 'theobject'
      expect(res.s3_endpoint).to eq 's3.amazon.com'
      expect(res.dlcheck_source).to eq 's3://s3.amazon.com/thebucket/theobject'
    end
    it 'handles dots in the bucketname' do
      allow(context)
          .to receive(:source).and_return('s3://thebucket.files/theobject')
      res.prepare(context)
      expect(res.bucket_name).to eq 'thebucket.files'
      expect(res.object_name).to eq 'theobject'
      expect(res.dlcheck_source).to eq 's3://s3.amazon.com/thebucket.files/theobject'
    end
    it 'installs the aws-sdk gem' do
      allow(context)
          .to receive(:source).and_return('s3://thebucket.files/theobject')
      res.prepare(context)
      expect(context).to have_received(:install_gem).with('aws-sdk', '3.0.1')
    end
  end
  describe 'download' do
    before do
      allow(context)
          .to receive(:source).and_return('s3://thebucket/theobject')
      allow(res)
          .to receive(:write_object).and_return(true)
      allow(res)
          .to receive(:write_dlcheck).and_return(true)
      allow(res)
          .to receive(:s3_client).and_return(s3_client)
      allow(s3_client)
          .to receive(:get_object).and_return(s3_object)
      allow(context)
          .to receive(:is_present?)
                  .and_return(true)
    end
    describe 'the file was not modified' do
      it 'does not download' do
        allow(res)
            .to receive(:create_dlcheck_from_object).and_return('abc')
        allow(res)
            .to receive(:read_cached_dlcheck).and_return('abc')
        expect(res.download(context)).to be(false)
      end
    end
    describe 'the has been modified' do
      it 'downloads the file' do
        allow(res)
            .to receive(:create_dlcheck_from_object).and_return('abc')
        allow(res)
            .to receive(:read_cached_dlcheck).and_return('abc2')
        allow(context)
            .to receive(:path).and_return('/some/path')
        expect(res.download(context)).to be(true)
        expect(res).to have_received(:write_object)
                           .with('thebucket', 'theobject', '/some/path')
      end
    end
  end
end