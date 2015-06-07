
module Kontena
  module DigitalOcean
    class GridProvisioner

      attr_reader :client

      def initialize(token)
        @client = DropletKit::Client.new(access_token: token)
        @cloud_config = Kontena::Configurator::NodeCloudConfig.new
      end

      def run!(opts)
        ssh_keys = []
        ssh_key = client.ssh_keys.all.find{|s| s.name == opts[:ssh_key_name]}
        ssh_keys << ssh_key.id if ssh_key
        initial_size = opts[:initial_size].to_i

        initial_size.times do |i|
          number = i + 1
          droplet = DropletKit::Droplet.new(
            name: "#{opts[:name]}-#{number}",
            ssh_keys: ssh_keys,
            region: opts[:region],
            image: 'coreos-beta',
            size: opts[:size],
            private_networking: true,
            user_data: @cloud_config.initial_user_data(opts[:version], initial_size,
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
    end
  end
end
