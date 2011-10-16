gem 'hoe', '>= 2.1.0'
require 'hoe'
require 'fileutils'
require './lib/Server-Health'

Hoe.plugin :newgem
# Hoe.plugin :website
# Hoe.plugin :cucumberfeatures

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
$hoe = Hoe.spec 'Server-Health' do
  self.developer 'Rheik van Eyck', 'rheikvaneyck@yahoo.de'
  self.post_install_message = 'PostInstall.txt' # TODO remove if post-install message not required
  self.rubyforge_name       = self.name # TODO this is default value
  self.extra_deps         = [['net-ssh','>= 2.1.4]',['net-scp','>= 1.0.4']]
end

require 'newgem/tasks'
Dir['tasks/**/*.rake'].each { |t| load t }

# TODO - want other tests/tasks run by default? Add them to the list
# remove_task :default
# task :default => [:spec, :features]
