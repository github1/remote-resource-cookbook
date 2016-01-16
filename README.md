# remote-resource-cookbook
Chef cookbook providing remote_resource resource

# usage
  
    remote_resource "/mys3resource.zip" do
      source 's3://s3.amazonaws.com/mybucket/myfile.zip'
    end
    
    remote_resource "/myhttpresource.zip" do
      source 'http://.../myfile.zip'
    end
