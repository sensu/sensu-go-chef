#
# Cookbook:: sensu-go-chef
# Resource:: ctl
#
# Copyright:: 2020 Sensu, Inc.
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
provides :sensu_ctl

include SensuCookbook::SensuPackageProperties

property :username, String, default: 'admin'
property :password, String, default: 'P@ssw0rd!', sensitive: true
property :backend_url, String, default: 'http://127.0.0.1:8080'
# WARNING: this will expose secrets to whatever is capturing
# the log output be it stdout (such as in CI) or log files
property :debug, [true, false], default: false

action_class do
  include SensuCookbook::Helpers::SensuCtl
end

action :install do
  if platform?('windows')
    include_recipe 'chocolatey'

    chocolatey_package 'sensu-cli' do
      action :install
      version new_resource.version unless new_resource.version == 'latest'
    end
  else
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
end

action :configure do
  if shell_out('sensuctl user list').error?
    converge_by 'Reconfiguring sensuctl' do
      unless platform?('windows')
        execute 'configure sensuctl' do
          command sensuctl_configure_cmd
          sensitive true unless new_resource.debug
        end
      end
      if platform?('windows')
        powershell_script 'configure sensuctl' do
          code sensuctl_configure_cmd
          sensitive true unless new_resource.debug
        end
      end
    end
  end
end

# This removes the folder we were previously putting the binary into.
action :cleanup_legacy_cookbook_install do
  if platform?('windows')
    windows_path sensuctl_bin do
      action :remove
    end

    directory sensuctl_bin do
      action :delete
      recursive true
    end
  end
end

action :uninstall do
  if platform?('windows')
    chocolatey_package 'sensu-cli' do
      action :remove
    end
  else
    package 'sensu-go-cli' do
      action :remove
    end
  end
end
