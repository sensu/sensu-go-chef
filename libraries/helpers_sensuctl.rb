module SensuCookbook
  module Helpers
    module SensuCtl
      def sensuctl_bin
        '/usr/bin/sensuctl'
      end

      def sensuctl_configure_opts
        opts = []
        opts << '--non-interactive'
        opts << ['--username', new_resource.username] unless new_resource.username.nil?
        opts << ['--password', new_resource.password] unless new_resource.password.nil?
        opts << ['--url', new_resource.backend_url] unless new_resource.backend_url.nil?
        opts
      end

      def sensuctl_configure_cmd
        [sensuctl_bin, 'configure', sensuctl_configure_opts].flatten
      end

      def sensuctl_asset_update_opts
        opts = []
        opts << ['--namespace', new_resource.namespace] if new_resource.namespace
      end

      def sensuctl_asset_update_cmd
        [sensuctl_bin, 'asset', 'update', new_resource.name, sensuctl_asset_update_opts].flatten
      end
    end
  end
end
