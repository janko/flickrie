require 'bundler'
Bundler::GemHelper.install_tasks
require 'rdoc/task' rescue nil

task "spec" do |task, args|
  system "bundle exec rspec -I spec --require 'spec_helper'"
end

Dir["spec/*_spec.rb"].each do |spec|
  task_name = File.basename(spec)[/.+(?=_spec\.rb)/]
  task "spec:#{task_name}" do
    system "bundle exec rspec -I spec --require 'spec_helper' #{spec}"
  end
end

task :console do
  begin
    require 'pry'
    system "bundle exec pry -I. --require 'flickrie' --require 'credentials'"
  rescue LoadError
    system "bundle exec irb -I. -r 'flickrie' -r 'credentials'"
  end
end

RDoc::Task.new :rerdoc => "rdoc:force" do |rdoc|
  rdoc.rdoc_files.include "lib/**/*.rb"
  rdoc.rdoc_dir = "doc"
end
