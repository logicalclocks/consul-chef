name 'consul'
maintainer 'Antonios Kouzoupis'
maintainer_email 'antonios@logicalclocks.com'
license 'Apache License Version 2.0'
description 'Installs/Configures HashiCorp Consul'
long_description 'Installs/Configures HashiCorp Consul for Hopsworks'
source_url 'https://github.com/logicalclocks/consul-chef'
issues_url 'https://github.com/logicalclocks/consul-chef/issues'
version '1.3.0'
chef_version '>= 12.1' if respond_to?(:chef_version)

depends 'conda'
depends 'kagent'


attribute "consul/user",
          :description => "System user to run the service",
          :type => 'string'

attribute "consul/group",
          :description => "Group id of consul user",
          :type => 'string'

attribute "consul/bin_url",
          :description => "URL to download Consul",
          :type => 'string'

attribute "consul/version",
          :description => "Version of Consul to install",
          :type => 'string'

attribute "consul/use_dnsmasq",
          :description => "Flag to control installation of dnsmasq. If set to false, DNS service discovery will NOT work",
          :type => 'string'

attribute "consul/configure_resolv_conf",
          :description => "Let cookbook configure dnsmasq resolv.conf",
          :type => 'string'

attribute "consul/effective_resolv_conf",
          :description => "Effective resolv.conf file. Be aware for Ubuntu /etc/resolv.conf is a symlink. Add here the source, not the symlink. Leave empty for auto-configuration",
          :type => 'string'

attribute "consul/http_api_port",
          :description => "Port of agent HTTP API",
          :type => 'string'
        
attribute "consul/domain",
          :description => "Domain to be handled by Consul",
          :type => 'string'

attribute "consul/bind_address",
          :description => "IP address Consul agent will bind to. You can also set a go-sockaddr template. Check https://www.consul.io/docs/agent/options.html#_bind for more information.",
          :type => 'string'

attribute "consul/retry_join/provider",
          :description => "Cloud provider for Cloud Auto-join, defaults to install/cloud",
          :type => 'string'

attribute "consul/retry_join/tag_key",
          :description => "Cloud Auto-join tag_key to join Consul master agent",
          :type => 'string'

attribute "consul/retry_join/tag_value",
          :description => "Cloud Auto-join tag_value to join Consul master agent",
          :type => 'string'

attribute "consul/master/ui",
          :description => "Flag to enable/disable the web UI",
          :type => 'string'

attribute "consul/health-check/max-attempts",
          :description => "Maximum number of attempts to retry the health check script before giving up",
          :type => 'string'

attribute "consul/health-check/multiplier",
          :description => "If a health check fails it will retry for max-attempts before being declared as dead. This attribute controls the sleep interval between consecutive attempts",
          :type => 'string'