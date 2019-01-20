#
# Cookbook Name:: sensu-go
# Resource:: user
#
# Copyright:: 2019 Sensu, Inc.
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

resource_name :sensu_user

include SensuCookbook::Helpers
include SensuCookbook::Helpers::SensuCtl
include SensuCookbook::SensuCommonProperties

property :username, String, name_property: true
property :password, String, required: true, sensitive: true # depends on chef 12.14
property :groups, Array, default: %w(view)
property :disabled, [true, false], default: false

action :create do
  require 'mixlib/shellout'

  # if users exists already, must call sensuctl user resinstate
  execute "sensuctl user create #{new_resource.username}" do
    command "#{sensuctl_bin} user create #{new_resource.username} --groups #{new_resource.groups.join(',')} --password #{new_resource.password}"
    only_if do
      cmd = Mixlib::ShellOut.new('sensuctl user list --format json')
      userlist = JSON.parse(cmd.run_command.stdout)
      user = userlist.detect { |u| u['username'] == new_resource.username }
      user.nil?
    end
    sensitive true
    action :run
  end
end

action :delete do
  # not possible, maybe an alias for disable?
  puts 'no-op'
end

action :disable do
  puts 'no-op'
end

action :reinstate do
  puts 'no-op'
end

action :modify do
  # an action to handle change-password, remove-group(s),add-group,set-groups
  puts 'no-op'
end

# Tricky one
# action :'change-password' do
# end
