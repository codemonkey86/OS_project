class LoadController < ApplicationController
  def index
    # # of sessions and memory usage, measured as % of system memory
    connections = `netstat -an | grep :3141 |wc -l`.gsub!("\n","").to_i
    procmemory = (`pmap #{Process.pid} | tail -1`[10,40].strip.gsub!("K","").to_f*100.0) / (1024* `free -mt`.match(/Mem:\s*([0-9]+)/)[1].to_f)
   
    sysmem = 0 
    `ps -ef | grep java`.split(/\n/).each do |jproc|
         pid = jproc.match(/.+?([0-9]+)/)    #pid
         sysmem += (`pmap #{Process.pid} | tail -1`[10,40].strip.gsub!("K","").to_f*100.0) / (1024* `free -mt`.match(/Mem:\s*([0-9]+)/)[1].to_f)
    end
    memory = (procmemory + sysmem)/2
    
    puts "Memory" + memory.to_s
    puts "connections" + connections.to_s
    load =memory + memory*(connections*(5.0/100))
      # each connection adds 5% to load calculation, representing potential load, also to facilitate demonstration
    render :text  => load.inspect
  end
end
