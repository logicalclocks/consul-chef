require 'openssl'
require 'net/http'
require 'uri'
require 'json'
require 'socket'

class ConsulHelper
    def initialize(node)
        @node = node
    end

    def get_service(name, tags)
        x509_helper = X509Helper.new @node
        crypto_dir = x509_helper.get_crypto_dir(@node['consul']['user'])
        hops_ca = "#{crypto_dir}/#{x509_helper.get_hops_ca_bundle_name()}"
        certificate = "#{crypto_dir}/#{x509_helper.get_certificate_bundle_name(@node['consul']['user'])}"
        key = "#{crypto_dir}/#{x509_helper.get_private_key_pkcs8_name(@node['consul']['user'])}"

        raw_certificate = File.read certificate
        certificate = OpenSSL::X509::Certificate.new raw_certificate

        raw_key = File.read key
        key = OpenSSL::PKey::RSA.new raw_key

        Net::HTTP.start(
            "localhost",
            @node['consul']['http_api_port'],
            :use_ssl => true,
            :verify_mode => OpenSSL::SSL::VERIFY_NONE,
            :cert => certificate,
            :key => key,
        ) do |http|
            uri = URI("/v1/health/service/#{name}")
            filter_tags = []
            tags.each { |st| filter_tags.push("\"#{st}\" in Service.Tags")}
            service_tags_filter = filter_tags.join(" and ")
            http_params = {
                :passing => true,
                :filter => service_tags_filter
            }
            uri.query = URI.encode_www_form(http_params)
            response = http.request_get(uri.to_s)
            if !response.kind_of? Net::HTTPSuccess
                raise "Error contacting local Consul agent Status: #{response.code} Reason: #{response.msg}"
            end
            body = JSON.parse(response.body)
            if body.empty?
                return nil, nil
            end
            return body[0]['Node']['Address'], body[0]['Service']['Port']
        end
    end

    def get_service_fqdn(prefix)
        unless prefix.end_with?(".")
            prefix = "#{prefix}."
        end
        datacenter = ""
        if @node['consul']['use_datacenter'].casecmp?("true")
            datacenter = "#{@node['consul']['datacenter']}."
        end
        "#{prefix}service.#{datacenter}#{@node['consul']['domain']}"
    end
end

class Chef
    class Recipe
        def consul_helper
            ConsulHelper.new(node)
        end
    end

    class Resource
        def consul_helper
            ConsulHelper.new(node)
        end
    end
end
