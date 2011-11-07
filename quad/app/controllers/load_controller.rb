class LoadController < ApplicationController

    def index
                 # # of sessions and CPU usage
       connections = `netstat -an | grep :4416 |wc -l`.gsub!("\n","").to_i
       memory = `pmap #{Process.pid} | tail -1`[10,40].strip.gsub!("K","").to_i
       puts "Memory" + memory.to_s
       puts "connections" + connections.to_s
       load =memory + memory*(connections*(1.0/100))
       render :text  => load.inspect

    end



end
