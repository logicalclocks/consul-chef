include_recipe "consul::default"
include_recipe "consul::security"

masters = private_recipe_ips("consul", "master")
if masters.length > 1
    if not node['consul']['retry_join']['provider'].empty? and not node['consul']['retry_join']['tag_key'].nil?
        masters = ["provider=#{node['consul']['retry_join']['provider'].strip} tag_key=#{node['consul']['retry_join']['tag_key'].strip} tag_value=#{node['consul']['retry_join']['tag_value'].strip}"]
    end
    num_masters = masters.length
else
    # If there is only one Consul master, do not template retry_join
    masters = nil
    num_masters = 1
end

crypto_dir = x509_helper.get_crypto_dir(node['consul']['user'])
hops_ca = "#{crypto_dir}/#{x509_helper.get_hops_ca_bundle_name()}"
certificate = "#{crypto_dir}/#{x509_helper.get_certificate_bundle_name(node['consul']['user'])}"
key = "#{crypto_dir}/#{x509_helper.get_private_key_pkcs8_name(node['consul']['user'])}"
template "#{node['consul']['conf_dir']}/consul.hcl" do
    source "config/master.hcl.erb"
    owner node['consul']['user']
    group node['consul']['group']
    mode 0750
    variables({
        :masters => masters,
        :num_masters => num_masters,
        :hops_ca => hops_ca,
        :certificate => certificate,
        :key => key
    })
end

include_recipe "consul::start"

bash 'wait-for-agent' do
    user node['consul']['user']
    group node['consul']['group']
    timeout 250
    code <<-EOH
        #{node['consul']['bin_dir']}/agent_waiter.sh
    EOH
    # Baking images for RonDB@Cloud we don't issue certificates so waiter will always fail.
    # In this case we set kagent/enabled: false
    only_if { node['kagent']['enabled'].casecmp?("true") }
end
