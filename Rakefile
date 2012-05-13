require 'bundler'
Bundler::GemHelper.install_tasks

task :spec, :spec do |task, args|
  command = "bundle exec rspec -I spec --require 'spec_helper'"
  if args['spec'].nil?
    system(command)
  else
    system(command + " spec/#{args['spec']}_spec.rb")
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

task :rdoc do
  system "rm -rf doc/"
  system "rdoc lib/"
end
