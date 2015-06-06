require 'net/http'
require 'uri'

module Kontena
  module DigitalOcean
    class GridProvisioner
      VERSIONS = {
        '0.6.1' => {
          agent: '0.6.1',
          weave: '0.10.0',
          cadvisor: '0.12.0'
        }
      }

      attr_reader :client

      def initialize(token)
        @client = DropletKit::Client.new(access_token: token)
      end

      def run!(opts)
        ssh_keys = []
        ssh_key = client.ssh_keys.all.find{|s| s.name == opts[:ssh_key_name]}
        ssh_keys << ssh_key.id if ssh_key
        versions = VERSIONS[opts[:version]]
        raise ArgumentError.new('Unknown version') unless versions

        initial_size = opts[:initial_size].to_i
        discovery_url = Net::HTTP.get(URI.parse("https://discovery.etcd.io/new?size=#{initial_size}"))

        puts "node version: #{opts[:version]}"
        puts "coreos version: coreos-beta"
        puts "etcd discovery url: #{discovery_url}"
        initial_size.times do |i|
          number = i + 1
          droplet = DropletKit::Droplet.new(
            name: "#{opts[:name]}-#{number}",
            ssh_keys: ssh_keys,
            region: opts[:region],
            image: 'coreos-beta',
            size: opts[:size],
            private_networking: true,
            user_data: erb(user_data_template,
              kontena_version: versions[:agent],
              weave_version: versions[:weave],
              cadvisor_version: versions[:cadvisor],
              master_uri: opts[:master_uri],
              discovery_url: discovery_url,
              grid_token: opts[:grid_token],
              node_number: number
            )
          )
          created = client.droplets.create(droplet)
          puts "Waiting for #{droplet.name} to start "
          until client.droplets.find(id: created.id).status == 'active' do
            print '.'
            sleep 1
          end
          print " started"
          puts ""
        end
      end

      def erb(template, vars)
        ERB.new(template).result(OpenStruct.new(vars).instance_eval { binding })
      end

      def user_data_template
        File.read(File.expand_path('./user_data/node.yml.erb', File.dirname(__FILE__)))
      end

    end
  end
end
