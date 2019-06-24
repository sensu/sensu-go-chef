#
# Cookbook Name:: sensu-go
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

resource_name :sensu_agent

include SensuCookbook::Helpers
include SensuCookbook::SensuPackageProperties
include SensuCookbook::SensuCommonProperties

property :agent_name, String, name_property: true
property :config, Hash, default: { "name": node['hostname'],
                                   "namespace": 'default',
                                   "backend-url": ['ws://127.0.0.1:8081'],
                                 }
action :install do
  # Linux installation - source package
  if node['platform'] != 'windows'
    packagecloud_repo new_resource.repo do
      type value_for_platform_family(
        %w(rhel fedora amazon) => 'rpm',
        'default' => 'deb'
      )
    end

    # Installs/upgrades sensu-go-agent package
    package 'sensu-go-agent' do
      if latest_version?(new_resource.version)
        action :upgrade
      else
        version new_resource.version
        action :install
      end
    end

    # render template at /etc/sensu/agent.yml for linux
    file ::File.join(new_resource.config_home, 'agent.yml') do
      content(stringify_keys(new_resource.config))
    end

    # Enable and start the sensu-agent service
    service 'sensu-agent' do
      if node['platform'] == 'ubuntu' && node['platform_version'].to_f == 14.04
        provider Chef::Provider::Service::Init
        action :start
      else
        action [:enable, :start]
      end
    end
  end

  # Installs msi for Sensu-Go
  if node['platform'] == 'windows'
    windows_package 'sensu-go-agent' do
      source 'https://s3-us-west-2.amazonaws.com/sensu.io/sensu-go/5.10.0/sensu-go-agent_5.10.0.4171_en-US.x64.msi'
      installer_type :custom
      version '5.10.0.4171'
    end

    # Adds install directory to path
    windows_path 'c:\\Program Files\\sensu\\sensu-agent\\bin'

    # render template at c:\Programdata\Sensu\config\agent.yml for windows
    file ::File.join('c:/ProgramData/Sensu/config', 'agent.yml') do
      content(stringify_keys(new_resource.config))
    end

    # Installs SensuAgent Service
    powershell_script 'SensuAgent Service' do
      code '.\\sensu-agent.exe service install'
      cwd 'c:/Program Files/sensu/sensu-agent/bin'
      not_if '((Get-Service SensuAgent).Name -eq "SensuAgent")'
    end

    # Enable and start SensuAgent service
    service 'SensuAgent' do
      action [:enable, :start]
    end
  end
end

action :uninstall do
  service 'sensu-agent' do
    action [:disable, :stop]
  end

  package 'sensu-go-agent' do
    action :remove
  end
end
