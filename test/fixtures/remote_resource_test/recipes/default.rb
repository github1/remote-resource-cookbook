ENV['AWS_ACCESS_KEY_ID']=node['aws_access_key_id']
ENV['AWS_SECRET_ACCESS_KEY']=node['aws_secret_access_key']

remote_resource "/mys3resource.zip" do
  source 's3://s3.amazonaws.com/fisolutions.latest/ffs-client.zip'
  notifies :create, "file[/myfile_for_s3]"
end

file "/myfile_for_s3" do
  action :nothing
end

remote_resource "/myhttpresource.zip" do
  source 'http://httpd.apache.org/images/httpd_logo_wide_new.png'
  notifies :create, "file[/myfile_for_http]"
end

file "/myfile_for_http" do
  action :nothing
end