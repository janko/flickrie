require 'bundler'
Bundler::GemHelper.install_tasks

task :console do
  credentials = [
    "Flickrie.api_key = ENV['FLICKR_API_KEY']",
    "Flickrie.shared_secret = ENV['FLICKR_SHARED_SECRET']",
    "Flickrie.access_token = ENV['FLICKR_ACCESS_TOKEN']",
    "Flickrie.access_secret = ENV['FLICKR_ACCESS_SECRET']"
  ].join('; ') if ENV['FLICKR_API_KEY']
  begin
    require 'pry'
    fill_credentials = %( --exec "#{credentials}; 'Credentials were filled in.'") if credentials
    system %(pry --require "flickrie") + fill_credentials.to_s
  rescue LoadError
    system "irb -r 'flickrie'"
  end
end

begin
  require 'rdoc/task'
  RDoc::Task.new :rerdoc => "rdoc:force" do |rdoc|
    rdoc.rdoc_files.include "lib/**/*.rb"
    rdoc.rdoc_dir = "doc"
  end
rescue LoadError
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
