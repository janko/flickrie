require 'bundler'
Bundler::GemHelper.install_tasks
require 'rdoc/task' rescue nil

desc "Run the specs (use spec:name to run a single spec)"
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

# copied from Rails
begin
  require 'rails/source_annotation_extractor'

  desc "Enumerate all annotations (use notes:optimize, :fixme, :todo for focus)"
  task :notes do
    SourceAnnotationExtractor.enumerate "OPTIMIZE|FIXME|TODO", :tag => true
  end

  namespace :notes do
    ["OPTIMIZE", "FIXME", "TODO"].each do |annotation|
      # desc "Enumerate all #{annotation} annotations"
      task annotation.downcase.intern do
        SourceAnnotationExtractor.enumerate annotation
      end
    end

    desc "Enumerate a custom annotation, specify with ANNOTATION=CUSTOM"
    task :custom do
      SourceAnnotationExtractor.enumerate ENV['ANNOTATION']
    end
  end
rescue LoadError
end
