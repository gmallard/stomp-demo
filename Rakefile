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
    ruby("basic/queue_put.rb")
  end
  #
  desc 'Run basic getter'
  task :getter do
    ruby("basic/queue_get.rb")
  end
end # namespace :basic
#
namespace :qeof do
  #
  desc 'Run queued EOF putter'
  task :putter do
    ruby("queue-eof/queue_put.rb")
  end
  #
  desc 'Run queued EOF putter with TRUE'
  task :putter_true do
    ruby("queue-eof/queue_put.rb", "TRUE")
  end
  #
  desc 'Run queued EOF getter'
  task :getter do
    ruby("queue-eof/queue_get.rb")
  end
end # namespace :qeof
#
namespace :threaded do
  #
  desc 'Run threaded example'
  task :getters do
    ruby("threaded/getters_demo.rb")
  end
end # namespace :threaded
#
namespace :monitor do
  #
  desc 'Run queue monitor'
  task :monitor do
    ruby("monitor/stompmon.rb")
  end
end # namespace :monitor
#
namespace :conn do
  #
  desc 'Run connection sender/receiver'
  task :sendreceive do
    ruby("connection/send_recv.rb")
  end
end # namespace :conn

