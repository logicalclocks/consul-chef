if node["kagent"]["enabled"].casecmp?("true")
  hopsworks_alt_url = "https://#{private_recipe_ip("hopsworks","default")}:8181"
  if node.attribute? "hopsworks"
    if node["hopsworks"].attribute? "https" and node["hopsworks"]['https'].attribute? ('port')
      hopsworks_alt_url = "https://#{private_recipe_ip("hopsworks","default")}:#{node['hopsworks']['https']['port']}"
    end
  end

  crypto_dir = x509_helper.get_crypto_dir(node['consul']['user'])
  kagent_hopsify "Generate x.509" do
    user node['consul']['user']
    crypto_directory crypto_dir
    hopsworks_alt_url hopsworks_alt_url
    action :generate_x509
  end
else
  # Create just the user directory without generating the certificates
  # It is needed when joining managed NDB nodes in Hopsworks cluster
  kagent_hopsify "Create user x.509 directory" do
    user node['consul']['user']
    crypto_directory x509_helper.get_crypto_dir(node['consul']['user'])
    action :create_user_directory
  end
end