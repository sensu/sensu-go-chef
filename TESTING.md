TESTING doc
========================

Bundler
-------
A ruby environment with Bundler installed is a prerequisite for using
the testing harness shipped with this cookbook. At the time of this
writing, it works with Ruby 2.0 and Bundler 1.5.3. All programs
involved, with the exception of Vagrant, can be installed by cd'ing
into the parent directory of this cookbook and running "bundle install"

Rakefile
--------
The Rakefile ships with a number of tasks, each of which can be ran
individually, or in groups. Typing "rake" by itself will perform style
checks with Rubocop and Foodcritic, ChefSpec with rspec, and
integration with Test Kitchen using the Vagrant driver by
default.Alternatively, integration tests can be ran with Test Kitchen
cloud drivers.

```
$ rake -T
rake integration:cloud    # Run Test Kitchen with cloud plugins
rake integration:vagrant  # Run Test Kitchen with Vagrant
rake spec                 # Run ChefSpec examples
rake style                # Run all style checks
rake style:chef           # Lint Chef cookbooks
rake style:ruby           # Run Ruby style checks
rake travis               # Run all tests on Travis
```

Style Testing
-------------
Ruby style tests can be performed by Rubocop by issuing either
```
bundle exec rubocop
```
or
```
rake style:ruby
```

Chef style tests can be performed with Foodcritic by issuing either
```
bundle exec foodcritic
```
or
```
rake style:chef
```

Spec Testing
-------------
Unit testing is done by running Rspec examples. Rspec will test any
libraries, then test recipes using ChefSpec. This works by compiling a
recipe (but not converging it), and allowing the user to make
assertions about the resource_collection.

Integration Testing
-------------------
Integration testing is performed by Test Kitchen. Test Kitchen will
use either the Vagrant driver or various cloud drivers to instantiate
machines and apply cookbooks. After a successful converge, tests are
uploaded and ran out of band of Chef. Tests should be designed to
ensure that a recipe has accomplished its goal.

Integration Testing using Vagrant
---------------------------------
Integration tests can be performed on a local workstation using
Virtualbox or VMWare. Detailed instructions for setting this up can be
found at the [Bento](https://github.com/chef/bento) project web site.

Integration tests using Vagrant can be performed with either
```
bundle exec kitchen test
```
or
```
rake integration:vagrant
```

Integration Testing using Cloud providers
-----------------------------------------
Integration tests can be performed on cloud providers using
Test Kitchen plugins. This cookbook ships a ```.kitchen.cloud.yml```
that references environmental variables present in the shell that
```kitchen test``` is ran from. These usually contain authentication
tokens for driving IaaS APIs, as well as the paths to ssh private keys
needed for Test Kitchen log into them after they've been created.

Examples of environment variables being set in ```~/.bash_profile```:
```
# digital_ocean
export DIGITAL_OCEAN_CLIENT_ID='your_bits_here'
export DIGITAL_OCEAN_API_KEY='your_bits_here'
export DIGITAL_OCEAN_SSH_KEY_IDS='your_bits_here'

# aws
export AWS_ACCESS_KEY_ID='your_bits_here'
export AWS_SECRET_ACCESS_KEY='your_bits_here'
export AWS_KEYPAIR_NAME='your_bits_here'

# joyent
export SDC_CLI_ACCOUNT='your_bits_here'
export SDC_CLI_IDENTITY='your_bits_here'
export SDC_CLI_KEY_ID='your_bits_here'
```

Integration tests using cloud drivers can be performed with either
```
export KITCHEN_YAML=.kitchen.cloud.yml
bundle exec kitchen test
```
or
```
rake integration:cloud
```
