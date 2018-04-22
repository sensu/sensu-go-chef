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

resource_name :sensu_agent

property :agent_id, String, name_property: true
property :version, String, default: 'latest'
property :repo, String, default: 'sensu/nightly'
property :config_home, String, default: '/etc/sensu'
property :config, Hash, default: { "agent-id": node['hostname'],
                                   "organization": 'default',
                                   "environment": 'default',
                                   "backend-url": ['ws://127.0.0.1:8081'],
                                 }
action :install do
  packagecloud_repo new_resource.repo do
    type value_for_platform_family(
      %w(rhel fedora amazon) => 'rpm',
      'default' => 'deb'
    )
  end

  package 'sensu-agent' do
    action :install
    version new_resource.version unless new_resource.version == 'latest'
  end

  # TODO: Remove this sad monkey patch if upstream PR is accepted
  # https://github.com/sensu/sensu-go/pull/1354
  if node['init_package'] == 'init'
    sensu_agent_init = '/etc/init.d/sensu-agent'
    ruby_block "Patch SYSV init runlevel file #{sensu_agent_init}" do # ~FC014
      block do
        f = Chef::Util::FileEdit.new(sensu_agent_init)
        f.search_file_replace_line(%r{^PATH=\/.*\:.*bin}, <<-EOH
#!/bin/sh
### BEGIN INIT INFO
# Provides:          sensu-agent
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start sensu-agent
# Description:       Enable the Sensu Agent service
### END INIT INFO

PATH=/sbin:/usr/sbin:/bin:/usr/bin
EOH
                                  )
        f.write_file
      end
      only_if { ::File.exist?(sensu_agent_init) }
      not_if { !::File.foreach(sensu_agent_init).grep(/BEGIN INIT/).empty? }
    end
  end

  # render template at /etc/sensu/agent.yml
  file ::File.join(new_resource.config_home, 'agent.yml') do
    content(new_resource.config.to_yaml)
  end

  service 'sensu-agent' do
    if node['platform'] == 'ubuntu' && node['platform_version'].to_f == 14.04
      provider Chef::Provider::Service::Init
      action :start
    else
      action [:enable, :start]
    end
  end
end

action :uninstall do
  service 'sensu-agent' do
    action [:disable, :stop]
  end

  package 'sensu-agent' do
    action :remove
  end
end
