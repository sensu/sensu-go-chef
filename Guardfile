# A sample Guardfile
# More info at https://github.com/guard/guard#readme

# This guard file has support for `foodcritic`, `rubocop` and `chefspec`
# CAUTION: If the `guard init` is run it will modify this file

# Foodcritic configuration
guard :foodcritic, cookbook_paths: '.' do
  watch(%r{attributes/.+\.rb$})
  watch(%r{providers/.+\.rb$})
  watch(%r{recipes/.+\.rb$})
  watch(%r{resources/.+\.rb$})
  watch(%r{templates/.+\.rb$})
  watch('metdata.rb')
end

# Rubocop configuration
guard :rubocop do
  watch(/%r{.+\.rb$}/)
  watch(%r{(?:.+/)?\.rubocop\.yml$}) { |m| File.dirname(m[0]) }
  watch('Guardfile')
  watch('Rakefile')
  watch('Berksfile')
end

# Chefspec configuration
guard :rspec, cmd: 'bundle exec rspec', all_on_start: false, notification: false do
  watch(%r{^spec/(.+)_spec\.rb$})
  watch(%r{^(recipes)/(.+)\.rb$}) { |m| "spec/unit/recipes/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb') { 'spec' }
end
