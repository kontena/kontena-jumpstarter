require 'erb'
require 'ostruct'
require 'net/http'
require 'uri'

module Kontena
  module Configurator
    class NodeCloudConfig

      VERSIONS = {
        '0.6.1' => {
          agent: '0.6.1',
          weave: '0.10.0',
          cadvisor: '0.12.0'
        }
      }

      def initial_user_data(version, initial_size, vars)
        versions = VERSIONS[version]
        raise ArgumentError.new('Unknown version') unless versions

        vars[:kontena_version] = versions[:agent]
        vars[:weave_version] = versions[:weave]
        vars[:cadvisor_version] = versions[:cadvisor]
        vars[:discovery_url] = Net::HTTP.get(URI.parse("https://discovery.etcd.io/new?size=#{initial_size}"))
        erb(user_data_template, vars)
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
