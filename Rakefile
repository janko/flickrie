require 'bundler'
Bundler::GemHelper.install_tasks

CURRENT_DIR = File.expand_path(File.dirname(__FILE__))

task :test do
  Dir["#{CURRENT_DIR}/test/**/*_test.rb"].each do |test_file|
    system "bundle exec turn -Itest #{test_file}"
  end
end

namespace :test do
  test_rbs = Dir["#{CURRENT_DIR}/test/*_test.rb"].
    map { |t| [File.basename(t).chomp('_test.rb').to_sym, t] }.
      each do |test_name, test_file|
        task(test_name) do
          system "bundle exec turn -Itest #{test_file}"
        end
      end
end

task :rdoc do
  system "rm -rf doc/"
  system "rdoc lib/"
end
