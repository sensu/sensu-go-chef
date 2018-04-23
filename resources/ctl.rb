#
# Cookbook Name:: sensu-go-chef
# Resource:: agent
#
# Copyright:: 2018 Sensu, Inc.
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

resource_name :sensu_ctl

property :version, String, default: 'latest'
property :repo, String, default: 'sensu/nightly'
property :username, String, default: 'admin'
property :password, String, default: 'P@ssw0rd!'
property :backend_url, String, default: 'http://127.0.0.1:8080'

action_class do
  include SensuCookbook::Helpers::SensuCtl
end

# load_current_value do
#   cluster_file = '/root/.config/sensu/sensuctl/cluster'
#   if ::File.exist?(cluster_file)
#     backend_url JSON.parse(IO.read(cluster_file))['api-url']
#   end
# end

action :install do
  packagecloud_repo new_resource.repo do
    type value_for_platform_family(
      %w(rhel fedora amazon) => 'rpm',
      'default' => 'deb'
    )
  end

  package 'sensu-cli' do
    action :install
    version new_resource.version unless new_resource.version == 'latest'
  end
end

action :configure do
  if shell_out('sensuctl user list').error?
    converge_by 'Reconfiguring sensuctl' do
      execute 'configure sensuctl' do
        command sensuctl_configure_cmd
        sensitive true
      end
    end
  end
end

action :uninstall do
  package 'sensu-cli' do
    action :remove
  end
end
