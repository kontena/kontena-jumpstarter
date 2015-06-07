require 'net/ssh'
require 'net/scp'

module Kontena
  module Configurator
    class NodeConfigurator

      def initialize(user_data, ip, ssh_key)
        @user_data = user_data
        @ip = ip
        @ssh_key = ssh_key
      end

      def apply
        retries = 0
        begin
          Net::SSH.start(@ip, "core", keys: [@ssh_key], paranoid: false) do |ssh|
            ssh.scp.upload! StringIO.new(@user_data), "/tmp/kontena-cloud-config.yml"
            ssh.exec!("sudo coreos-cloudinit --from-file /tmp/kontena-cloud-config.yml") do |channel, stream, data|
              puts data
            end
            ssh.close
          end
        rescue Errno::ETIMEDOUT => exc
          retries += 1
          if retries < 20
            sleep 1
            retry
          else
            raise exc
          end
        end
      end
    end
  end
end
