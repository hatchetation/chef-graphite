default['graphite']['version'] = "0.9.9"
default['graphite']['python_version'] = "2.6"

default['graphite']['carbon']['uri'] = "http://launchpadlibrarian.net/82112362/carbon-#{node['graphite']['version']}.tar.gz"
default['graphite']['carbon']['checksum'] = "b3d42e3b93c09"

default['graphite']['whisper']['uri'] = "http://launchpadlibrarian.net/82112367/whisper-#{node['graphite']['version']}.tar.gz"
default['graphite']['whisper']['checksum'] = "66c05eafe8d86"

default['graphite']['graphite_web']['uri'] = "http://launchpadlibrarian.net/82112308/graphite-web-#{node['graphite']['version']}.tar.gz"
default['graphite']['graphite_web']['checksum'] = "cc78bab7fb26b"

default['graphite']['carbon']['line_receiver_interface'] =   "127.0.0.1"
default['graphite']['carbon']['pickle_receiver_interface'] = "127.0.0.1"
default['graphite']['carbon']['cache_query_interface'] =     "127.0.0.1"
default['graphite']['carbon']['service_type'] = "runit"

default['graphite']['password'] = "change_me"
default['graphite']['url'] = "graphite"
default['graphite']['url_aliases'] = []
default['graphite']['listen_port'] = "80"
default['graphite']['base_dir'] = "/opt/graphite"
default['graphite']['doc_root']     = "#{node['graphite']['base_dir']}/webapp"
default['graphite']['conf_dir']    = "/etc/graphite"

default['graphite']['server_auth_method'] = "none" # or openid, htauth
default['graphite']['sysadmin_email']     = "root@localhost"
