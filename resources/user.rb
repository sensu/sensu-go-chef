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

action_class do
  require 'mixlib/shellout'
  def current_users
    cmd = Mixlib::ShellOut.new('sensuctl user list --format json')
    JSON.parse(cmd.run_command.stdout)
  end

  def current_user
    current_users.detect { |u| u['username'] == new_resource.username }
  end

  def exists?
    current_users.any? { |u| u['username'] == new_resource.username }
  end

  def disabled?
    current_users.any? { |u| u['username'] == new_resource.username && u['disabled'] == true }
  end

  def current_groups
    current_user['groups'].sort
  end

  def group_args
    new_resource.groups.join(',')
  end

  def groups_match?
    current_groups == new_resource.groups.sort
  end
end

action :create do
  execute "sensuctl user create #{new_resource.username}" do
    command "#{sensuctl_bin} user create #{new_resource.username} --groups #{group_args} --password #{new_resource.password}"
    not_if { exists? }
    sensitive true
  end
end

action :disable do
  execute "sensuctl user disable #{new_resource.username}" do
    command "#{sensuctl_bin} user disable #{new_resource.username} --skip-confirm"
    not_if { disabled? }
  end
end

action :reinstate do
  execute "sensuctl user reinstate #{new_resource.username}" do
    command "#{sensuctl_bin} user reinstate #{new_resource.username}"
    only_if { disabled? }
  end
end

action :modify do
  # It is difficult to make this action fully idempotent without also tracking the users passwords
  if property_is_set?(:password)
    execute "sensuctl user change-password #{new_resource.username}" do
      command "sensuctl user change-password #{new_resource.username} --new-password #{password}"
      sensitive true
    end
  end

  # Instead of handling remove/add group commands just support idempotent set-group for now
  if property_is_set?(:groups)
    execute "sensuctl user set-groups #{new_resource.username} #{group_args}" do
      not_if { groups_match? }
    end
  end
end
