require_relative '../../../libraries/s3.rb'

describe 'RemoteResource::S3RemoteResource' do
  let(:context) {
    c = double('context')
    allow(c)
      .to receive(:install_gem).and_return(true)
    allow(c)
      .to receive(:extract_metadata).and_return({})
    allow(c)
      .to receive(:write_value_to_file)
    allow(c)
      .to receive(:cache_path).and_return('/the/cache')
    allow(c)
      .to receive(:is_present_in_cache?)
        .and_return(false)
    allow(c)
      .to receive(:copy_from_cache)
    allow(c)
      .to receive(:cached_file)
        .and_return('/some/cached/file')
    allow(c)
      .to receive(:write_value_to_file)
    c
  }
  let(:res) {
    RemoteResource::S3RemoteResource
      .new
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
      expect(res.s3_endpoint).to eq 's3.amazonaws.com'
      expect(res.dlcheck_source).to eq 's3://s3.amazonaws.com/thebucket/theobject'
    end
    it 'handles dots in the bucketname' do
      allow(context)
        .to receive(:source).and_return('s3://thebucket.files/theobject')
      res.prepare(context)
      expect(res.bucket_name).to eq 'thebucket.files'
      expect(res.object_name).to eq 'theobject'
      expect(res.dlcheck_source).to eq 's3://s3.amazonaws.com/thebucket.files/theobject'
    end
    it 'installs the aws-sdk gem' do
      allow(context)
        .to receive(:source).and_return('s3://thebucket.files/theobject')
      res.prepare(context)
      expect(context).to have_received(:install_gem).with('aws-sdk-s3', '1.60.1')
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
        .to receive(:s3_object).and_return(s3_object)
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
        allow(res)
          .to receive(:get_metadata_from_object).and_return('abc')
        expect(res.download(context)).to be(false)
      end
    end
    describe 'the file was modified' do
      it 'downloads the file' do
        allow(res)
          .to receive(:create_dlcheck_from_object).and_return('abc')
        allow(res)
          .to receive(:read_cached_dlcheck).and_return('abc2')
        allow(context)
          .to receive(:path).and_return('/some/path')
        allow(res)
          .to receive(:get_metadata_from_object).and_return('abc')
        expect(res.download(context)).to be(true)
        expect(res).to have_received(:write_object)
          .with(s3_object, '/some/cached/file')
        expect(context).to have_received(:copy_from_cache)
      end
    end
    describe 'extract metadata' do
      it 'extracts metadata to a file' do
        allow(context)
          .to receive(:extract_metadata).and_return({ :something => '/some/metadata/file' })
        allow(res)
          .to receive(:create_dlcheck_from_object).and_return('abc')
        allow(res)
          .to receive(:read_cached_dlcheck).and_return('abc2')
        allow(context)
          .to receive(:path).and_return('/some/path')
        allow(res)
          .to receive(:get_metadata_from_object).and_return('abc')
        res.download(context)
        expect(res).to have_received(:get_metadata_from_object).with(any_args, 'something')
        expect(context).to have_received(:write_value_to_file).with('/some/metadata/file', 'abc')
      end
    end
  end
end