module SensuCookbook
  module Helpers
    module SensuBackend
      def sensu_backend_bin
        if node['platform'] != 'windows'
          '/usr/sbin/sensu-backend'
        else
          'c:\Program Files\Sensu\sensu-cli\bin\sensuctl'
        end
      end

      def sensu_backend_init_opts
        opts = []
        opts << ['--cluster-admin-username', new_resource.username] unless new_resource.username.nil?
        opts << ['--cluster-admin-password', new_resource.password] unless new_resource.password.nil?
        opts
      end

      def sensu_backend_init_cmd
        if node['platform'] != 'windows'
          [sensu_backend_bin, 'init', sensu_backend_init_opts].flatten
        else
          ['sensu-backend.exe', 'init', sensu_backend_init_opts].flatten
        end
      end
    end
  end
end
