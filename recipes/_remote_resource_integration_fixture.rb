ENV['AWS_REGION']=node['aws_region']
ENV['AWS_ACCESS_KEY_ID']=node['aws_access_key_id']
ENV['AWS_SECRET_ACCESS_KEY']=node['aws_secret_access_key']

(1..2).each do |n|
  remote_resource "/mys3resource.zip #{n}" do
    path '/mys3resource.zip'
    source 's3://s3.amazonaws.com/chef.remote-resource-cookbook/test_file'
    notifies :create, "file[/myfile_for_s3_#{n}]"
  end
end

file '/myfile_for_s3_1' do
  action :nothing
end

file '/myfile_for_s3_2' do
  action :nothing
end

(1..2).each do |n|
  remote_resource "/myhttpresource.jpg #{n}" do
    path '/myhttpresource.jpg'
    source 'https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_120x44dp.png'
    notifies :create, "file[/myfile_for_http_#{n}]"
  end
end

file '/myfile_for_http_1' do
  action :nothing
end

file '/myfile_for_http_2' do
  action :nothing
end