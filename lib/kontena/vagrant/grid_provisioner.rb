
module Kontena
  module Vagrant
    class GridProvisioner

      attr_reader :client

      def initialize
        @cloud_config = Kontena::Configurator::NodeCloudConfig.new
      end

      def run!(opts)
        initial_size = opts[:initial_size].to_i
        vagrant_root_dir = File.join(Dir.pwd, ".kontena-vagrant-nodes")
        FileUtils.mkdir(vagrant_root_dir) unless Dir.exists?(vagrant_root_dir)
        initial_size.times do |i|
          number = i + 1
          provision_node(number)
          user_data = @cloud_config.initial_user_data(opts[:version], initial_size,
            master_uri: opts[:master_uri],
            grid_token: opts[:grid_token],
            node_number: number
          )
          configure_node(user_data, "192.168.66.#{number + 1}", '~/.vagrant.d/insecure_private_key')
        end
      end

      def provision_node(number)
        vagrant_dir = File.join(Dir.pwd, ".kontena-vagrant-nodes/node-#{number}")
        FileUtils.mkdir(vagrant_dir) unless Dir.exists?(vagrant_dir)

        Dir.chdir(vagrant_dir) do |dir|
          File.write(File.join(dir, 'Vagrantfile'), erb(File.read(vagrant_file), node_number: number))
          Open3.popen2("vagrant up") do |stdin, stdout, wait|
            while line = stdout.gets
              puts line
            end
          end
        end
      end

      def configure_node(user_data, ip, ssh_key)
        configurator = Kontena::Configurator::NodeConfigurator.new(user_data, ip, ssh_key)
        configurator.apply
      end

      def vagrant_file
        File.expand_path('./templates/Vagrantfile.node', File.dirname(__FILE__))
      end

      def erb(template, vars)
        ERB.new(template).result(OpenStruct.new(vars).instance_eval { binding })
      end
    end
  end
end
