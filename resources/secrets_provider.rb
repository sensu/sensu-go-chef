#
# Cookbook:: sensu-go
# Resource:: secrets_provider
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

resource_name :sensu_secrets_provider
provides :sensu_secrets_provider
unified_mode true

action_class do
  include SensuCookbook::Helpers
end

property :address, String, required: true
property :max_retries, Integer
property :provider_type, String, default: 'Env'
property :rate_limiter, Hash
property :timeout, String
property :tls, Hash
property :token, String
property :version, String, default: 'v2'
alias_method :resource_type, :provider_type

action :create do
  directory object_dir do
    action :create
    recursive true
  end

  file object_file do
    content JSON.generate(secrets_provider_from_resource)
    notifies :run, "execute[sensuctl create -f #{object_file}]"
  end

  execute "sensuctl create -f #{object_file}" do
    action :nothing
  end
end

action :delete do
  file object_file do
    action :delete
    notifies :run, "execute[sensuctl delete -f #{object_file} --skip-confirm]", :before
  end

  execute "sensuctl delete -f #{object_file} --skip-confirm" do
    action :nothing
  end
end
