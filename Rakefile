require 'rake/rdoctask' 
#
namespace :doc do
#
  desc 'Generate RDoc documentation'
  Rake::RDocTask.new do |rd|
    rd.main = "README.txt"
    rd.rdoc_files.include("README.txt", "**/*.rb")
  end
#
end # namespace :doc 
#
namespace :basic do
  #
  desc 'Run basic putter'
  task :putter do
    # ? How to pass parms via "load" ???
    # load "basic/queue_put.rb"
    system("ruby basic/queue_put.rb")
  end
  #
  desc 'Run basic getter'
  task :getter do
    system("ruby basic/queue_get.rb")
  end
end # namespace :basic
#
namespace :qeof do
  #
  desc 'Run queued EOF putter'
  task :putter do
    system("ruby queue-eof/queue_put.rb")
  end
  #
  desc 'Run queued EOF putter with TRUE'
  task :putter_true do
    system("ruby queue-eof/queue_put.rb TRUE")
  end
  #
  desc 'Run queued EOF getter'
  task :getter do
    # load "basic/queue_get.rb"
    system("ruby queue-eof/queue_get.rb")
  end
end # namespace :qeof
#
namespace :threaded do
  #
  desc 'Run threaded example'
  task :getters do
    system("ruby threaded/getters-demo.rb")
  end
end # namespace :threaded

