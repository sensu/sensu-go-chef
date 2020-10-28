#
# Cookbook:: sensu-go
# Resource:: etcd_replicator
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

resource_name :sensu_etcd_replicator
provides :sensu_etcd_replicator

action_class do
  include SensuCookbook::Helpers

  def missing_secure_transport_property(name)
    !new_resource.insecure && name.nil?
  end

  def check_resource_semantics!
    error_msg = <<-EOH
\n\nFor the resource: #{new_resource.name} the property 'insecure' is set to 'false'.
This is the default and enables transport security for replication.
Transport security requires both 'cert' and 'key' properties of this resource to be set to valid local paths.
Please set these values.
EOH

    if missing_secure_transport_property(new_resource.cert)
      raise error_msg
    end

    if missing_secure_transport_property(new_resource.key)
      raise error_msg
    end
  end
end

# Set sane platform property default so users generally should not need it
default_ca_cert = value_for_platform_family(
  %w(rhel fedora amazon) => '/etc/ssl/certs/ca-bundle.crt',
  'debian' => '/etc/ssl/certs/ca-certificates.crt',
  'windows' => ''
)

# Properties correspond to upstream spec attributes
# https://docs.sensu.io/sensu-go/latest/operations/deploy-sensu/etcdreplicators/#spec-attributes
property :ca_cert, String, default: default_ca_cert
property :cert, String
property :key, String
property :insecure, [true, false], default: false
property :url, String, required: true
property :api_version, String, default: 'core/v2'
property :resource, String, required: true
property :namespace, String
property :replication_interval_seconds, Integer, default: 30

action :create do
  directory object_dir(false) do
    action :create
    recursive true
  end

  file object_file(false) do
    content JSON.generate(etcd_replicator_from_resource)
    notifies :run, "execute[sensuctl create -f #{object_file(false)}]"
  end

  execute "sensuctl create -f #{object_file(false)}" do
    action :nothing
  end
end
