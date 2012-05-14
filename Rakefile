require 'bundler'
Bundler::GemHelper.install_tasks

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
