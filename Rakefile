require 'bundler'
Bundler::GemHelper.install_tasks

CURRENT_DIR = File.expand_path(File.dirname(__FILE__))

task :test do
  Dir["#{CURRENT_DIR}/test/**/*_test.rb"].each do |test|
    system "ruby -Ilib -Itest #{test}"
  end
end

namespace :test do
  test_rbs = Dir["#{CURRENT_DIR}/test/*_test.rb"]
  test_rbs.map { |t| File.basename(t).chomp('_test.rb') }.each do |test_name|
    task(test_name.to_sym) do
      system "ruby -Ilib -Itest test/#{test_name}_test.rb"
    end
  end
end
