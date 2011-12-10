#We calculate the load as an average of the system and process memory usage (calculated as % of system max)
#Also factored in is the # of connections to the port app is running on
#The influence of this is weighted heavily to ensure demonstration will show load changes after a reasonalbe # of requests,
#even if machines start out with significantly different loads
class LoadController < ApplicationController
  def index
    # # of sessions and CPU usage
    connections = `netstat -an | grep :4416 |wc -l`.gsub!("\n","").to_i
    procmemory = (`pmap #{Process.pid} | tail -1`[10,40].strip.gsub!("K","").to_f*100.0)  / (1024* `free -mt`.match(/Mem:\s*([0-9]+)/)[1].to_f)
    
    sysmem = 0 
    # the pops here is to not include the two "process" found with ps the command itself which are gone by time pmap occurs
    pid_array =  `ps -ef | grep java`.split(/\n/)
    pid_array.each do |jproc|
           if jproc.match(/script\/server/)
                pid = jproc.match(/.+?([0-9]+)/)[1].to_i    #pid
                sysmem += (`pmap #{pid} | tail -1`[10,40].strip.gsub!("K","").to_f*100.0)  / (1024* `free -mt`.match(/Mem:\s*([0-9]+)/)[1].to_f)
            end
     end
     memory = (procmemory + sysmem)/2
     puts "Memory pre connection" + memory.to_s
     load =memory + memory*(connections*(75.0/100))
     puts "number connections" + connections.to_s
     puts "Memory post connection" + load.to_s
       # each connection adds 5% to load calculation, representing potential load, also to facilitate demonstration
     render :text  => load.inspect
  end
end
