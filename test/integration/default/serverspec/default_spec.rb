require_relative './spec_helper'

describe file('/files/aws_s3_test_file') do
  it { should be_file }
  its(:size) { should > 0 }
end

describe file('/files/myfile_for_s3_1') do
  it { should be_file }
end

describe file('/files/myfile_for_s3_2') do
  it { should_not exist }
end

describe file('/files/http_test_file') do
  it { should be_file }
  its(:size) { should > 0 }
end

describe file('/files/myfile_for_http_1') do
  it { should be_file }
end

describe file('/files/myfile_for_http_2') do
  it { should_not exist }
end
