module Kontena
  module DigitalOcean
    class MasterProvisioner

      attr_reader :client

      def initialize(token)
        @client = DropletKit::Client.new(access_token: token)
        @cloud_config = Kontena::Configurator::MasterCloudConfig.new
      end

      def run!(opts)
        raise ArgumentError.new("#{opts[:name]} droplet already exists") if master_exists?(opts[:name])

        ssh_keys = []
        ssh_key = client.ssh_keys.all.find{|s| s.name == opts[:ssh_key_name]}
        ssh_keys << ssh_key.id if ssh_key
        droplet = DropletKit::Droplet.new(
          name: opts[:name],
          ssh_keys: ssh_keys,
          region: opts[:region],
          image: 'coreos-beta',
          size: opts[:size],
          private_networking: true,
          user_data: @cloud_config.initial_user_data(opts[:version], admin_email: opts[:email])
        )
        created = client.droplets.create(droplet)
        puts 'Waiting for master node to start '
        until client.droplets.find(id: created.id).status == 'active' do
          print '.'
          sleep 1
        end
        master = client.droplets.find(id: created.id)
        puts ""
        puts "Kontena master node created successfully!"

        master
      end

      def master_exists?(name)
        client.droplets.all.any?{|d| d.name == name}
      end
    end
  end
end
