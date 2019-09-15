# remote-resource-cookbook
Chef cookbook providing remote_resource resource

# Usage
Add to Berksfile
```ruby
cookbook 'remote_resource', git: 'https://github.com/github1/remote-resource-cookbook'
```

Use in cookbook recipe:

_s3 resources_
```ruby
remote_resource "/mys3resource.zip" do
  source 's3://mybucket/myfile.zip'
end
```

_http(s) resources_
```ruby
remote_resource "/myhttpresource.zip" do
  source 'https://.../myfile.zip'
end
```