require_relative './spec_helper'

describe file('/files/aws_s3_test_file') do
  it { should be_file }
  its(:size) { should > 0 }
  its(:content) { should match /this is a test/ }
end

describe file('/files/aws_s3_test_file_version') do
  it { should be_file }
  its(:size) { should > 0 }
  its(:content) { should match /1\.0\.0/ }
end

describe file('/files/aws_s3_test_file_something_else') do
  it { should be_file }
  its(:size) { should == 0 }
  its(:content) { should match /^$/ }
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
