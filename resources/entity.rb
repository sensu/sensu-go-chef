#
# Cookbook:: sensu-go
# Resource:: entity
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

include SensuCookbook::SensuMetadataProperties
include SensuCookbook::SensuCommonProperties

resource_name :sensu_entity
provides :sensu_entity

action_class do
  include SensuCookbook::Helpers
end

property :deregister, [true, false]
property :deregistration, Hash
property :entity_class, String
property :redact, Array
property :sensu_agent_version, String
property :subscriptions, Array
property :system, Hash
property :user, String
property :namespace, String, default: 'default'
property :entity_name, String

action :create do
  directory object_dir do
    action :create
    recursive true
  end

  file object_file do
    content JSON.generate(entity_from_resource)
    notifies :run, "execute[sensuctl create -f #{object_file}]"
  end

  execute "sensuctl create -f #{object_file}" do
    action :nothing
  end
end
