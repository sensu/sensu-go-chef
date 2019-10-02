#
# Cookbook:: sensu-go-chef
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

include SensuCookbook::SensuPackageProperties

property :username, String, default: 'admin'
property :password, String, default: 'P@ssw0rd!', sensitive: true
property :backend_url, String, default: 'http://127.0.0.1:8080'
# WARNING: this will expose secrets to whatever is capturing
# the log output be it stdout (such as in CI) or log files
property :debug, [TrueClass, FalseClass], default: false

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
  if node['platform'] != 'windows'
    packagecloud_repo new_resource.repo do
      type value_for_platform_family(
        %w(rhel fedora amazon) => 'rpm',
        'default' => 'deb'
      )
    end

    package 'sensu-go-cli' do
      action :install
      version new_resource.version unless new_resource.version == 'latest'
    end
  end

  if node['platform'] == 'windows'
    # This is awaiting a packaged method to be delivered, but provides a resource currently.
    include_recipe 'seven_zip'

    directory 'c:\sensutemp'

    powershell_script 'Download Sensuctl' do
      code "Invoke-WebRequest https://s3-us-west-2.amazonaws.com/sensu.io/sensu-go/#{node['sensu-go']['ctl_version']}/sensu-enterprise-go_#{node['sensu-go']['ctl_version']}_windows_amd64.tar.gz  -OutFile c:/sensutemp/sensu-enterprise-go_#{node['sensu-go']['ctl_version']}_windows_amd64.tar.gz"
      not_if "Test-Path c:/sensutemp/sensu-enterprise-go_#{node['sensu-go']['ctl_version']}_windows_amd64.tar.gz"
    end

    seven_zip_archive 'Extract Sensuctl Gz' do
      path "c:/sensutemp/sensu-enterprise-go_#{node['sensu-go']['ctl_version']}_windows_amd64.tar"
      source "c:/sensutemp/sensu-enterprise-go_#{node['sensu-go']['ctl_version']}_windows_amd64.tar.gz"
      overwrite true
      timeout   30
    end

    seven_zip_archive 'Extract Sensuctl Tar' do
      path "c:/sensutemp/sensu-enterprise-go_#{node['sensu-go']['ctl_version']}_windows_amd64"
      source "c:/sensutemp/sensu-enterprise-go_#{node['sensu-go']['ctl_version']}_windows_amd64.tar"
      overwrite true
      timeout   30
    end

    directory sensuctl_bin do
      recursive true
    end

    remote_file "#{sensuctl_bin}\\sensuctl.exe" do
      source "file:///c:/sensutemp/sensu-enterprise-go_#{node['sensu-go']['ctl_version']}_windows_amd64/sensuctl.exe"
    end

    windows_path sensuctl_bin

    directory 'c:\sensutemp' do
      action :delete
      recursive true
    end
  end
end

action :configure do
  if shell_out('sensuctl user list').error?
    converge_by 'Reconfiguring sensuctl' do
      execute 'configure sensuctl' do
        command sensuctl_configure_cmd
        sensitive true unless new_resource.debug
      end
    end
  end
end

action :uninstall do
  if node['platform'] != 'windows'
    package 'sensu-go-cli' do
      action :remove
    end
  end

  if node['platform'] == 'windows'
    windows_path sensuctl_bin do
      action :remove
    end

    directory sensuctl_bin do
      action :delete
      recursive true
    end
  end
end
