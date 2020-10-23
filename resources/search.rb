#
# Cookbook:: sensu-go
# Resource:: search
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

resource_name :sensu_search
provides :sensu_search

property :namespace, String, default: 'default'
property :parameters, Array, required: true, callbacks: {
  'List can only contain valid sensu search parameters' => lambda do |arry|
    arry.all? do |e|
      e.start_with?('action', 'check', 'class',
                    'entity', 'event', 'label', 'published',
                    'silenced', 'status', 'subscription', 'type')
    end
  end,
         }
property :resource, String, required: true

action_class do
  include SensuCookbook::Helpers
end

action :create do
  directory object_dir(plural = false) do
    action :create
    recursive true
  end

  file object_file(plural = false) do
    content JSON.generate(search_from_resource)
    notifies :run, "execute[sensuctl create -f #{object_file(plural = false)}]"
  end

  execute "sensuctl create -f #{object_file(plural = false)}" do
    action :nothing
  end
end

action :delete do
  execute "sensuctl delete -f #{object_file(plural = false)}" do
    action :run
    notifies :delete, "file[#{object_file(plural = false)}]"
  end

  file object_file(plural = false) do
    action :nothing
  end
end
