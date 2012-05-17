require 'bundler'
Bundler::GemHelper.install_tasks

task :default => :spec

desc "Run the specs (use spec:name to run a single spec)"
task :spec do |task, args|
  system "rspec -Ispec"
end

Dir["spec/*_spec.rb"].each do |spec|
  task_name = File.basename(spec)[/.+(?=_spec\.rb)/]
  task :"spec:#{task_name}" do
    system "rspec -Ispec #{spec}"
  end
end

desc "Open the console with credentials (API key, secret etc.) already filled in"
task :console do
  File.open("credentials.rb", "w") do |f|
    f.write <<-CREDENTIALS
      Flickrie.api_key = ENV['FLICKR_API_KEY']
      Flickrie.shared_secret = ENV['FLICKR_SHARED_SECRET']
      Flickrie.access_token = ENV['FLICKR_ACCESS_TOKEN']
      Flickrie.access_secret = ENV['FLICKR_ACCESS_SECRET']
    CREDENTIALS
  end
  begin
    require 'pry'
    system "pry --require 'flickrie' --require './credentials'"
  rescue LoadError
    system "irb -r 'flickrie' -r './credentials'"
  end
  FileUtils.remove_file "credentials.rb"
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
