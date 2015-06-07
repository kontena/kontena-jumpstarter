require 'sshkey'

module Kontena
  module DigitalOcean
    class GridProvisioner

      attr_reader :client

      def initialize(token)
        @client = DropletKit::Client.new(access_token: token)
        @cloud_config = Kontena::Configurator::NodeCloudConfig.new
      end

      def run!(opts)
        raise ArgumentError.new('Invalid ssh key') unless File.exists?(File.expand_path(opts[:ssh_key]))

        ssh_keys = []
        ssh_key = SSHKey.new(File.read(File.expand_path(opts[:ssh_key])))
        ssh_keys = [ssh_key.md5_fingerprint]
        initial_size = opts[:initial_size].to_i

        initial_size.times do |i|
          number = i + 1
          node = provision_node(number, ssh_keys, opts)
          user_data = @cloud_config.initial_user_data(opts[:version], initial_size,
            master_uri: opts[:master_uri],
            grid_token: opts[:grid_token],
            node_number: number
          )
          configure_node(user_data, node.public_ip, opts[:ssh_key])
        end
      end

      def provision_node(number, ssh_keys, opts)
        droplet = DropletKit::Droplet.new(
          name: "#{opts[:name]}-#{number}",
          ssh_keys: ssh_keys,
          region: opts[:region],
          image: 'coreos-beta',
          size: opts[:size],
          private_networking: true
        )
        created = client.droplets.create(droplet)
        until client.droplets.find(id: created.id).status == 'active' do
          sleep 1
        end
        client.droplets.find(id: created.id)
      end

      def configure_node(user_data, ip, ssh_key)
        configurator = Kontena::Configurator::NodeConfigurator.new(user_data, ip, ssh_key)
        configurator.apply
      end
    end
  end
end
