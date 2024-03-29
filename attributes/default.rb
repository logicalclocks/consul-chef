default['consul']['user']                       = node['install']['user'].empty? ? 'consul' : node['install']['user']
default['consul']['user_id']                    = '1500'
default['consul']['group']                      = node['install']['user'].empty? ? 'consul' : node['install']['user']
default['consul']['group_id']                   = '1500'
default['consul']["dir"]                        = node['install']['dir'].empty? ? "/srv/hops" : node['install']['dir']

default['consul']['data_volume']['root_dir']    = "#{node['data']['dir']}/consul"
default['consul']['data_volume']['logs_dir']    = "#{node['consul']['data_volume']['root_dir']}/logs"

default['dnsmasq']['data_volume']['root_dir']   = "#{node['data']['dir']}/dnsmasq"
default['dnsmasq']['data_volume']['logs_dir']   = "#{node['dnsmasq']['data_volume']['root_dir']}/logs"
default['dnsmasq']['home']                      = "#{node['consul']['dir']}/dnsmasq"
default['dnsmasq']['logs_dir']                  = "#{node['dnsmasq']['home']}/logs"

default['consul']['home']                       = "#{node['consul']['dir']}/consul"
default['consul']['conf_dir']                   = "#{node['consul']['home']}/consul.d"
default['consul']['data_dir']                   = "#{node['consul']['home']}/data_dir"
default['consul']['bin_dir']                    = "#{node['consul']['home']}/bin"
default['consul']['logs_dir']                   = "#{node['consul']['home']}/logs"

default['consul']['version']                    = "1.7.0"
default['consul']['bin_url']                    = "#{node['download_url']}/consul/consul_#{node['consul']['version']}_linux_amd64.zip"
default['consul']['use_dnsmasq']                = "true"
default['consul']['systemd_restart_dnsmasq']    = "true"
default['consul']['configure_resolv_conf']      = "true"
default['consul']['effective_resolv_conf']      = ""
default['consul']['http_api_port']              = "8501"
default['consul']['rpc_port']                   = "8300"
default['consul']['domain']                     = "consul"
default['consul']['datacenter']                 = "lc"
default['consul']['use_datacenter']             = "false"

default['consul']['bind_address']               = ""
# Default bind to localhost but accepts any go-sockaddr template
default['consul']['client_address']             = '{{ GetPrivateIPs }} {{ GetAllInterfaces | include "flags" "loopback" | include "type" "ipv4" | join "address" " " }}'
default['consul']['retry_join']['provider']     = node['install']['cloud']
default['consul']['retry_join']['tag_key']      = nil
default['consul']['retry_join']['tag_value']    = nil

default['consul']['master']['ui']               = "true"

default['consul']['health-check']['retryable-check-file'] = "#{node['consul']['bin_dir']}/retryable_health_check.sh"
default['consul']['health-check']['max-attempts']         = 7
default['consul']['health-check']['multiplier']           = 1.2

default['consul']['metrics']['prometheus_retention_time'] = "1m"

default['consul']['wan']['enabled']                = "false"
default['consul']['wan']['serf_port']              = "8302"
default['consul']['wan']['nodes']                  = nil

# 7 days
default['consul']['log_rotate_max_files']   = "7"
# 300mb
default['consul']['log_rotate_bytes']       = "314572800"