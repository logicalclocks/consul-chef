default['consul']['user']                       = node['install']['user'].empty? ? 'consul' : node['install']['user']
default['consul']['group']                      = node['install']['user'].empty? ? 'consul' : node['install']['user']
default['consul']["dir"]                        = node['install']['dir'].empty? ? "/srv/hops" : node['install']['dir']
default['consul']['home']                       = "#{node['consul']['dir']}/consul"
default['consul']['conf_dir']                   = "#{node['consul']['home']}/consul.d"
default['consul']['data_dir']                   = "#{node['consul']['home']}/data_dir"
default['consul']['bin_dir']                    = "#{node['consul']['home']}/bin"

default['consul']['version']                    = "1.7.0"
default['consul']['bin_url']                    = "#{node['download_url']}/consul/consul_#{node['consul']['version']}_linux_amd64.zip"
default['consul']['use_dnsmasq']                = "true"
default['consul']['configure_resolv_conf']      = "true"
default['consul']['effective_resolv_conf']      = ""
default['consul']['http_api_port']              = "8501"
default['consul']['domain']                     = "consul"

default['consul']['bind_address']               = ""
default['consul']['retry_join']['provider']     = node['install']['cloud']
default['consul']['retry_join']['tag_key']      = nil
default['consul']['retry_join']['tag_value']    = nil

default['consul']['master']['ui']               = "true"

default['consul']['health-check']['retryable-check-file'] = "#{node['consul']['bin_dir']}/retryable_health_check.sh"
default['consul']['health-check']['max-attempts']         = 7
default['consul']['health-check']['multiplier']           = 1.2