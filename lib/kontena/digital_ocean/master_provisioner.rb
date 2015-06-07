require 'sshkey'

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
        raise ArgumentError.new('Invalid ssh key') unless File.exists?(File.expand_path(opts[:ssh_key]))
        ssh_key = SSHKey.new(File.read(File.expand_path(opts[:ssh_key])))
        ssh_keys = [ssh_key.md5_fingerprint]
        droplet = DropletKit::Droplet.new(
          name: opts[:name],
          ssh_keys: ssh_keys,
          region: opts[:region],
          image: 'coreos-beta',
          size: opts[:size],
          private_networking: true
        )
        puts "Creating master node to DigitalOcean ..."
        puts "Region: #{droplet.region}"
        puts "Size: #{droplet.size}"
        created = client.droplets.create(droplet)
        puts ""
        print "Waiting for droplet to start ."
        until client.droplets.find(id: created.id).status == 'active' do
          sleep 1
          print "."
        end
        master = client.droplets.find(id: created.id)

        puts ""
        puts "Starting to configure master node ..."
        user_data = @cloud_config.initial_user_data(opts[:version], admin_email: opts[:email])
        configurator = Kontena::Configurator::NodeConfigurator.new(user_data, master.public_ip, opts[:ssh_key])
        configurator.apply

        puts "You can now connect to master using:"
        puts "kontena connect http://#{master.public_ip}:8080"

        master
      end

      def master_exists?(name)
        client.droplets.all.any?{|d| d.name == name}
      end
    end
  end
end
