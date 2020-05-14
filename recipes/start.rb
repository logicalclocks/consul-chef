case node["platform_family"]
when "debian"
    service_target = "/lib/systemd/system/consul.service"
when "rhel"
    service_target = "/usr/lib/systemd/system/consul.service"
end

if node['install']['localhost'].casecmp?("true")
    bind_address = "127.0.0.1"
    consul_tls_server_name = "localhost"
else
    if node['consul']['bind_address'].empty?
        bind_address = my_private_ip()
    else
        bind_address = "'#{node['consul']['bind_address']}'"
    end
    consul_tls_server_name = "$(hostname -f | tr -d '[:space:]')"
end

template service_target do
    source "init/consul.service.erb"
    owner 'root'
    group 'root'
    mode 0644
    variables({
        :bind_address => bind_address,
        :consul_tls_server_name => consul_tls_server_name
    })
end

systemd_unit "consul.service" do
    action [:start]
end

if node['kagent']['enabled'].casecmp?("true")
    kagent_config "consul" do
      service "Consul"
    end
end

if node['services']['enabled'].casecmp?("true")
    systemd_unit "consul.service" do
        action :enable
    end
end