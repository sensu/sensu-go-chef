name 'sensu-go'
maintainer 'Sensu Community'
maintainer_email 'support@sensuapp.com'
license 'MIT'
description 'Installs/Configures Sensu Go'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.0.4'

chef_version '>= 12.5'

%w(
  aix
  ubuntu
  debian
  centos
  redhat
  fedora
  scientific
  oracle
  amazon
  suse
  windows
).each do |os|
  supports os
end

issues_url 'https://github.com/sensu/sensu-go-chef/issues'
source_url 'https://github.com/sensu/sensu-go-chef'

depends 'packagecloud'
