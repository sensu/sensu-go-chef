module SensuCookbook
  module Helpers
    module SensuCtl
      def sensuctl_bin
        '/usr/bin/sensuctl'
      end

      def sensuctl_configure_opts
        opts = []
        opts << '--non-interactive'
        opts << "--username #{new_resource.username}" unless new_resource.username.nil?
        opts << "--password #{new_resource.password}" unless new_resource.password.nil?
        opts << "--url #{new_resource.backend_url}" unless new_resource.backend_url.nil?
        opts
      end

      def sensuctl_configure_cmd
        [sensuctl_bin, 'configure', sensuctl_configure_opts].join(' ').strip
      end
    end
  end
end
