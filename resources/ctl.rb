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
property :password, String, default: 'P@ssw0rd!'
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
  # Linux installation - source package
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
    # Windows installation
    powershell_script 'WebRequest SensuCtl' do
      code 'Invoke-WebRequest https://s3-us-west-2.amazonaws.com/sensu.io/sensu-go/5.10.2/sensu-enterprise-go_5.10.2_windows_amd64.tar.gz  -OutFile C:/Users/Public/Desktop/sensu-enterprise-go_5.10.2_windows_amd64.tar.gz'
      not_if '(Get-Item "C:/Users/Public/Desktop/sensu-enterprise-go_5.10.2_windows_amd64.tar.gz").name -eq "sensu-enterprise-go_5.10.2_windows_amd64.tar.gz"'
    end

    # Dependency until native windows packaging resolved
    include_recipe 'seven_zip'

    # tar.gz to tar
    seven_zip_archive 'Extract Sensuctl' do
      path      'C:/Users/Public/Desktop/'
      source    'C:/Users/Public/Desktop/sensu-enterprise-go_5.10.2_windows_amd64.tar.gz'
      overwrite true
      timeout   30
    end

    # Extract tar
    seven_zip_archive 'Extract Sensuctl' do
      path      'c:/Program Files/Sensu/sensu-cli/bin/sensuctl'
      source    'C:/Users/Public/Desktop/sensu-enterprise-go_5.10.2_windows_amd64.tar'
      overwrite true
      timeout   30
    end

    # Add install path to windows path
    windows_path 'c:\Program Files\Sensu\sensu-cli\bin\sensuctl'
  end
end

action :configure do
  if node['platform'] != 'windows'
    if shell_out('sensuctl user list').error?
      converge_by 'Reconfiguring sensuctl' do
        execute 'configure sensuctl' do
          command sensuctl_configure_cmd
          sensitive new_resource.debug
        end
      end
    end
  end

  if node['platform'] == 'windows'
    if execute('sensuctl user list').error?
      converge_by 'Reconfiguring sensuctl' do
        execute 'configure sensuctl' do
          command sensuctl_configure_cmd
          sensitive new_resource.debug
        end
      end
    end
  end
end

action :uninstall do
  package 'sensu-go-cli' do
    action :remove
  end
end
