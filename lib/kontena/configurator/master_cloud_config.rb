require 'erb'
require 'ostruct'

module Kontena
  module Configurator
    class MasterCloudConfig

      VERSIONS = {
        '0.6.1' => {
          api: '0.6.1',
          redis: '2.8',
          mongo: '3.0',
          haproxy: 'latest'
        }
      }

      def initial_user_data(version, vars)
        versions = VERSIONS[version]
        raise ArgumentError.new('Unknown version') unless versions

        vars[:kontena_version] = versions[:api]
        vars[:redis_version] = versions[:redis]
        vars[:mongo_version] = versions[:mongo]
        vars[:haproxy_version] = versions[:haproxy]
        erb(user_data_template, vars)
      end

      def erb(template, vars)
        ERB.new(template).result(OpenStruct.new(vars).instance_eval { binding })
      end

      def user_data_template
        File.read(File.expand_path('./user_data/master.yml.erb', File.dirname(__FILE__)))
      end
    end
  end
end
