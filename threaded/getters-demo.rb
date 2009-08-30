require 'rubygems'
require 'stomp'
#
MAX_GETTERS = 2 - 1
MAX_WKE = 4 - 1
#
puts "Max Gettters: #{MAX_GETTERS + 1}"
puts "Max WKEs: #{MAX_WKE + 1}"
#
getters = (0..MAX_GETTERS).map do |i|
  Thread.new("consumer #{i}", i) do |name, getter_num|
    client = Stomp::Client.open "login", "passcode", "localhost", 51613
    received = nil
    queue_name = "/queue/test#{getter_num}"
    client_name = "rubyClient#{getter_num}"
    client.subscribe(queue_name, {
                    "persistent" => true,
                    "client-id" => client_name,
            } ) do |message|
      # puts "#{p message}"
      puts "#{name} Got Reply: BODY=#{message.body} on #{message.headers['destination']}"
      received = message
    end
    sleep 0.5 until received
    client.close
    puts "getter #{name} ending"
  end
end
#
client = Stomp::Client.open "login", "passcode", "localhost", 51613
puts "starting puts"
next_queue_num = MAX_GETTERS
for i in 0..MAX_WKE do
   next_queue_num += 1
   next_queue_num = 0 if next_queue_num > MAX_GETTERS
   queue_name = "/queue/test#{next_queue_num}"
   client_name = "Client#{next_queue_num}"
   message = "WKE Num: #{i} to queue #{queue_name}"
   puts "Putting: #{message}"
   client.send(queue_name, message, {
    "persistent" => true,
    "client-id" => client_name,
    "reply-to" => queue_name,
    }
  )
end
puts "ending puts"
client.close
#
puts "Starting getter wait"
getters.each {|th| th.join}
puts "Complete"
#

