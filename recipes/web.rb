include_recipe "apache2::mod_python"
include_recipe "apache2::mod_headers"

package "python-cairo-dev"
package "python-django"
package "python-django-tagging"
package "python-memcache"
package "python-rrdtool"

basedir = node['graphite']['base_dir']
version = node['graphite']['version']
pyver = node['graphite']['python_version']


sysadmins = if Chef::Config[:solo]
  Chef::Log.warn("This recipe uses search. Chef Solo does not support search.")
  []
else
  search(:users, 'groups:sysadmin')
end

if node['public_domain']
  case node.chef_environment
  when "production"
    public_domain = node['public_domain']
  else
    public_domain = "#{node.chef_environment}.#{node['public_domain']}"
  end
else
  public_domain = node['domain']
end

remote_file "/usr/src/graphite-web-#{version}.tar.gz" do
  source node['graphite']['graphite_web']['uri']
  checksum node['graphite']['graphite_web']['checksum']
end

execute "untar graphite-web" do
  command "tar xzf graphite-web-#{version}.tar.gz"
  creates "/usr/src/graphite-web-#{version}"
  cwd "/usr/src"
end

execute "install graphite-web" do
  command "python setup.py install"
  creates "#{node['graphite']['doc_root']}/graphite_web-#{version}-py#{pyver}.egg-info"
  cwd "/usr/src/graphite-web-#{version}"
end

directory node['graphite']['conf_dir'] do
  owner node['apache']['user']
  group node['apache']['group']
  recursive true
end

directory "#{basedir}/storage" do
  owner node['apache']['user']
  group node['apache']['group']
end

directory "#{basedir}/storage/log" do
  owner node['apache']['user']
  group node['apache']['group']
end

%w{ webapp whisper }.each do |dir|
  directory "#{basedir}/storage/log/#{dir}" do
    owner node['apache']['user']
    group node['apache']['group']
  end
end

template "#{basedir}/bin/set_admin_passwd.py" do
  source "set_admin_passwd.py.erb"
  mode 00755
end

cookbook_file "#{basedir}/storage/graphite.db" do
  action :create_if_missing
  notifies :run, "execute[set admin password]"
end

execute "set admin password" do
  command "#{basedir}/bin/set_admin_passwd.py root #{node['graphite']['password']}"
  action :nothing
end

file "#{basedir}/storage/graphite.db" do
  owner node['apache']['user']
  group node['apache']['group']
  mode 00644
end

case node['graphite']['server_auth_method']
when "openid"
  include_recipe "apache2::mod_auth_openid"
else
  template "#{node['graphite']['conf_dir']}/htpasswd.users" do
    source "htpasswd.users.erb"
    owner node['apache']['user']
    group node['apache']['group']
    mode 0640
    variables(
      :sysadmins => sysadmins
    )
  end
end

apache_site "000-default" do
  enable false
end

template "#{node['apache']['dir']}/sites-available/graphite.conf" do
  source "graphite-vhost.conf.erb"
  mode 0644
  variables :public_domain => public_domain
  if ::File.symlink?("#{node['apache']['dir']}/sites-enabled/graphite.conf")
    notifies :reload, "service[apache2]"
  end
end

apache_site "graphite"
