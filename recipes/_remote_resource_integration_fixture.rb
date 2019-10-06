ENV['AWS_REGION']=node['aws_region']
ENV['AWS_ACCESS_KEY_ID']=node['aws_access_key_id']
ENV['AWS_SECRET_ACCESS_KEY']=node['aws_secret_access_key']

::FileUtils.rm_rf('/files')

%w( /files/aws_s3_test_file
    /files/http_test_file
    /files/myfile_for_s3_1
    /files/myfile_for_s3_2
    /files/myfile_for_http_1
    /files/myfile_for_http_2
).each do |name|
  # do this so files are in resource_collection for notifications
  file "#{name}" do
    action :delete
  end
end

(1..2).each do |n|
  remote_resource "aws_s3_test_file #{n}" do
    path '/files/aws_s3_test_file'
    source 's3://chef.remote-resource-cookbook/test_file'
    notifies :create, "file[/files/myfile_for_s3_#{n}]"
  end
end

(1..2).each do |n|
  remote_resource "http_test_file #{n}" do
    path '/files/http_test_file'
    source 'https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_120x44dp.png'
    notifies :create, "file[/files/myfile_for_http_#{n}]"
  end
end
