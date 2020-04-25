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

template "#{node['consul']['conf_dir']}/consul.hcl" do
    source "config/master.hcl.erb"
    owner node['consul']['user']
    group node['consul']['group']
    mode 0750
    variables({
        :masters => masters,
        :num_masters => num_masters
    })
end

include_recipe "consul::start"