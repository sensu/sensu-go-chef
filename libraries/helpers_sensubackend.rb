module SensuCookbook
  module Helpers
    module SensuBackend
      def sensu_backend_bin
        '/usr/sbin/sensu-backend'
      end

      def sensu_backend_init_opts
        opts = []
        opts << ['--cluster-admin-username', new_resource.username] unless new_resource.username.nil?
        opts << ['--cluster-admin-password', new_resource.password] unless new_resource.password.nil?
        opts
      end

      def sensu_backend_init_cmd
        [sensu_backend_bin, 'init', sensu_backend_init_opts].flatten
      end
    end
  end
end
