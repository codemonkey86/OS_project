class LoadController < ApplicationController
  def index
    # # of sessions and CPU usage
    connections = `netstat -an | grep :3141 |wc -l`.gsub!("\n","").to_i
    memory = (`pmap #{Process.pid} | tail -1`[10,40].strip.gsub!("K","").to_f*100.0) / (1024* `free -mt`.match(/Mem:\s*([0-9]+)/)[1].to_f)
    puts "Memory" + memory.to_s
    puts "connections" + connections.to_s
    load =memory + memory*(connections*(5.0/100))
    render :text  => load.inspect
  end
end
