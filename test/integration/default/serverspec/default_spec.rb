require 'spec_helper'

describe file('/mys3resource.zip') do
  it { should be_file }
end

describe file('/myfile_for_s3_1') do
  it { should be_file }
end

describe file('/myfile_for_s3_2') do
  it { should_not exist }
end

describe file('/myhttpresource.jpg') do
  it { should be_file }
end

describe file('/myfile_for_http_1') do
  it { should be_file }
end

describe file('/myfile_for_http_2') do
  it { should_not exist }
end
