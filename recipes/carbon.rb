package "python-twisted"
package "python-simplejson"

basedir = node['graphite']['base_dir']
version = node['graphite']['version']
pyver = node['graphite']['python_version']

remote_file "/usr/src/carbon-#{version}.tar.gz" do
  source node['graphite']['carbon']['uri']
  checksum node['graphite']['carbon']['checksum']
end

execute "untar carbon" do
  command "tar xzf carbon-#{version}.tar.gz"
  creates "/usr/src/carbon-#{version}"
  cwd "/usr/src"
end

execute "install carbon" do
  command "python setup.py install"
  creates "#{basedir}/lib/carbon-#{version}-py#{pyver}.egg-info"
  cwd "/usr/src/carbon-#{version}"
end

template "#{basedir}/conf/carbon.conf" do
  owner node['apache']['user']
  group node['apache']['group']
  variables( :line_receiver_interface => node['graphite']['carbon']['line_receiver_interface'],
             :pickle_receiver_interface => node['graphite']['carbon']['pickle_receiver_interface'],
             :cache_query_interface => node['graphite']['carbon']['cache_query_interface'],
             :log_updates => node['graphite']['carbon']['log_updates'],
             :max_update_rate => node['graphite']['carbon']['max_update_rate'], )
  notifies :restart, "service[carbon-cache]"
end

template "#{basedir}/conf/storage-schemas.conf" do
  owner node['apache']['user']
  group node['apache']['group']
end

execute "carbon: change graphite storage permissions to apache user" do
  command "chown -R #{node['apache']['user']}:#{node['apache']['group']} #{basedir}/storage"
  only_if do
    f = File.stat("#{node['graphite']['base_dir']}/storage")
    f.uid == 0 and f.gid == 0
  end
end

directory "#{basedir}/lib/twisted/plugins/" do
  owner node['apache']['user']
  group node['apache']['group']
end

service_type = node['graphite']['carbon']['service_type']
include_recipe "#{cookbook_name}::#{recipe_name}_#{service_type}"
