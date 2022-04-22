#
# Cookbook:: sensu-go
# Resource:: auth_oidc
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

resource_name :sensu_auth_oidc
provides :sensu_auth_oidc
unified_mode true

action_class do
  include SensuCookbook::Helpers
end

property :additional_scopes, Array
property :client_id, String, required: true
property :client_secret, String, required: true, sensitive: true
property :disable_offline_access, [true, false], default: false
property :redirect_uri, String
property :server, String, required: true
property :groups_claim, String, default: 'groups'
property :groups_prefix, String
property :username_prefix, String
property :username_claim, String, default: 'email'
property :resource_type, String, default: 'oidc'

action :create do
  directory object_dir(false) do
    action :create
    recursive true
  end

  file object_file(false) do
    content JSON.generate(auth_oidc_from_resource)
    notifies :run, "execute[sensuctl create -f #{object_file(false)}]"
  end

  execute "sensuctl create -f #{object_file(false)}" do
    action :nothing
  end
end
