#
# Cookbook:: sensu-go
# Resource:: global_config
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

resource_name :sensu_global_config
provides :sensu_global_config
unified_mode true

action_class do
  include SensuCookbook::Helpers
end

property :always_show_local_cluster, [true, false], default: false

# https://docs.sensu.io/sensu-go/latest/web-ui/webconfig-reference/#default-preferences-attributes
property :default_preferences, Hash, callbacks: {
  'Should contain only valid default preference attributes' => lambda do |defaults|
    defaults.keys do |pref|
      [:page_size, :theme].include?(pref)
    end && defaults.keys.length <= 2 # Only 2 valid preference attributes right now
  end,
  'Theme setting must be an allowed value' => lambda do |defaults|
    %w(sensu classic uchiwa tritanopia deuteranopia).include?(defaults[:theme])
  end,
         }
property :link_policy, Hash, callbacks: {
  'Should be a valid link policy attribute' => lambda do |link|
    link.keys do |pref|
      [:allow_list, :urls].include?(pref)
    end
  end,
  'Link policy URLs should be an array' => lambda do |link|
    link[:urls].is_a?(Array)
  end,
  'Link policy allow list should be a boolean' => lambda do |link|
    [true, false].include? link[:allow_list]
  end,
         }

action :create do
  directory object_dir(false) do
    action :create
    recursive true
  end

  file object_file(false) do
    content JSON.generate(global_config_from_resource)
    notifies :run, "execute[sensuctl create -f #{object_file(false)}]"
  end

  execute "sensuctl create -f #{object_file(false)}" do
    action :nothing
  end
end
