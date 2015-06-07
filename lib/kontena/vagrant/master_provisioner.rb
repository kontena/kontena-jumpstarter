require 'fileutils'
require 'open3'
module Kontena
  module Vagrant
    class MasterProvisioner

      attr_reader :client

      def initialize
        @cloud_config = Kontena::Configurator::MasterCloudConfig.new
      end

      def run!(opts)
        provision_node

        user_data = @cloud_config.initial_user_data(opts[:version], admin_email: opts[:email])
        configure_node(user_data, '192.168.66.100', '~/.vagrant.d/insecure_private_key')
      end

      def provision_node
        vagrant_dir = File.join(Dir.pwd, '.kontena-vagrant-master')
        FileUtils.mkdir(vagrant_dir) unless Dir.exists?(vagrant_dir)
        Dir.chdir(vagrant_dir) do |dir|
          FileUtils.cp(vagrant_file, File.join(dir, 'Vagrantfile'))
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
        File.expand_path('./templates/Vagrantfile.master', File.dirname(__FILE__))
      end
    end
  end
end
