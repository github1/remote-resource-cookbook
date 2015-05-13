require 'spec_helper'

describe file('/mys3resource.zip') do
  it { should be_file }
end

describe file('/myhttpresource.zip') do
  it { should be_file }
end