# Install and configure dnsmasq
if node['consul']['use_dnsmasq'].casecmp("true")
    package 'dnsmasq'

    if node['consul']['configure_resolv_conf'].casecmp("true") &&  ! ::File.exist?('/etc/dnsmasq.d/default')

        interface_name = consul_helper.get_ifname_from_ip(my_private_ip())
        # Disable systemd-resolved for Ubuntu
        case node["platform_family"]
        when "debian"
            # Follow steps from here https://github.com/hashicorp/terraform-aws-consul/tree/master/modules
            package "iptables-persistent"

            bash "Set debconf" do
                user 'root'
                group 'root'
                code <<-EOH
                    echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections
                    echo iptables-persistent iptables-persistent/autosave_v6 boolean true | debconf-set-selections
                EOH
            end

            bash "Configure systemd-resolved" do
                user 'root'
                group 'root'
                code <<-EOH
                    iptables -t nat -A OUTPUT -d localhost -p udp -m udp --dport 53 -j REDIRECT --to-ports 8600
                    iptables -t nat -A OUTPUT -d localhost -p tcp -m tcp --dport 53 -j REDIRECT --to-ports 8600
                    iptables-save | tee /etc/iptables/rules.v4
                    ip6tables-save | sudo tee /etc/iptables/rules.v6
                    sed -i "s/#DNS=/DNS=127.0.0.2/g" /etc/systemd/resolved.conf
                    sed -i "s/#Domains=/Domains=~#{node['consul']['domain']}/g" /etc/systemd/resolved.conf
                EOH
            end

            template "/etc/dnsmasq.d/default" do
                source "dnsmasq-conf.erb"
                owner 'root'
                group 'root'
                mode 0755
                variables({
                    :resolv_conf => nil,
                    :if_name => interface_name,
                    :dnsmasq_ip => "127.0.0.2"
                })
            end

            systemd_unit "systemd-resolved.service" do
                action [:restart]
            end
        when "rhel"
            directory "/var/run/dnsmasq" do
                owner 'root'
                group 'root'
                mode '755'
                action
            end
            if node['consul']['effective_resolv_conf'].empty?
                effective_resolv_conf = "/etc/resolv.conf"
            else
                effective_resolv_conf = node['consul']['effective_resolv_conf']
            end
            bash "copy resolv.conf to dnsmasq directory" do
                user 'root'
                group 'root'
                code <<-EOH
                    set -e
                    cp #{effective_resolv_conf} /var/run/dnsmasq
                EOH
                notifies :run, 'bash[configure-resolv.conf]', :immediately
                not_if { ::File.exist?('/var/run/dnsmasq/resolv.conf') }
            end
            resolv_conf = "/var/run/dnsmasq/resolv.conf"

            template "/etc/dnsmasq.d/default" do
                source "dnsmasq-conf.erb"
                owner 'root'
                group 'root'
                mode 0755
                variables({
                    :resolv_conf => resolv_conf,
                    :if_name => interface_name,
                    :dnsmasq_ip => "127.0.0.1"
                })
            end

            bash "configure-resolv.conf" do
                user 'root'
                group 'root'
                code <<-EOH
                    set -e
                    cp /etc/resolv.conf /etc/resolv.conf.bak
                    rm -f /etc/resolv.conf
                    echo "nameserver 127.0.0.1" > /etc/resolv.conf
                    chmod 644 /etc/resolv.conf
                EOH
                action :nothing
            end
        end

        systemd_unit "dnsmasq.service" do
            action :restart
        end
    end
end

template "#{node['consul']['conf_dir']}/systemd_env_vars" do
    source "init/systemd_env_vars.erb"
    owner node['consul']['user']
    group node['consul']['group']
    mode 0750
end

bash "export security env variables for client" do
    user node['consul']['user']
    group node['consul']['group']
    cwd node['consul']['home']
    code <<-EOH
        echo "export CONSUL_CACERT=#{node["kagent"]["certs"]["root_ca"]}" >> .bashrc
        echo "export CONSUL_CLIENT_CERT=#{node["kagent"]["certs_dir"]}/pub.pem" >> .bashrc
        echo "export CONSUL_CLIENT_KEY=#{node["kagent"]["certs_dir"]}/priv.key" >> .bashrc
        echo "export CONSUL_HTTP_ADDR=https://127.0.0.1:#{node['consul']['http_api_port']}" >> .bashrc
        echo "export CONSUL_TLS_SERVER_NAME=$(hostname -f | tr -d '[:space:]')" >> .bashrc
    EOH
    not_if "grep CONSUL_TLS_SERVER_NAME #{node['consul']['home']}"
end

template node['consul']['health-check']['retryable-check-file'] do
    source "retryable_health_check.sh.erb"
    owner node['consul']['user']
    group node['consul']['group']
    mode 0755
end