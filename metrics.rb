#This script provides the following metrics for our distributed systems project:
# It is configurable in terms of number of maximum number of request mades.
# and the interval (in terms of # of requests)  at which to get balance info for all machines
# requests are randomly generated to chose both the machine to initiate the request at and for what service
# parameters are also randomized to alter loads for the given services

# Key metrics after this script runs are:
#     The array named after each machine which contains the given machine's load at the desired intervals used to see how it changes throughout
#     The request hash which tracks how many requests a given machine handled for a given service
#     The servicecount hash which maps the # of requests made for each service
#     Error urls which keeps track of URL's that either failed to connect, or connected, but could not find service

##SCRIPT REQUIRES RUBY  1.8.7 for curb to work!
require 'rubygems'
require 'curb'
require 'json'

def curl_load(url)
  begin
     c = Curl::Easy.http_get(url)
  rescue Exception => e
     return false
  end
  return c.body_str
end

def pi_put(url)
  begin 
    c = Curl::Easy.http_post(url, Curl::PostField.content('digits', rand(15)+1))
  rescue Exception => e
     return false
  end
end

def fib_put(url)
  begin
    c = Curl::Easy.http_post(url,   Curl::PostField.content('digits', rand(10**10)+1))
  rescue Exception => e
    return fasle
  end
end

def convert_put(url)
  begin 
    c = Curl::Easy.http_post(url,  Curl::PostField.content('value', rand(10**10)+1), Curl::PostField.content('base', rand(65)+2))
  rescue Exception => e
     return false
  end
end

def quad_put(url)
  begin
    c = Curl::Easy.http_post(url, Curl::PostField.content('ainput', rand(10**10)+1), Curl::PostField.content('binput', rand(10**10)+1), Curl::PostField.content('cinput', rand(10**10)+1))
  rescue Exception => e
    return false
  end
end



servicehash = {0 => "pi", 1 => "quad", 2 => "fib", 3 => "convert"}
machinehash = {0 => "master", 1 => "endlesswaltz", 2 => "steve-laptop"}
request = {}
request["master"] = Hash.new(0)
request["steve-laptop"] = Hash.new(0)
request["endlesswaltz"] = Hash.new(0)
servicecount = Hash.new(0)
  
max = 100

requests = 0
success = 0
time = 0
master = []
endlesswaltz = []
stevelaptop = []
error_urls = []
while requests < max 
     requests += 10
     if   requests % 1 == 0
       # every 10 requests  build up arrays to then analyze later, figure out timing
       load = curl_load("http://" + machinehash[0].to_s + ":3000/services/sysload")
       master << load if load
       load = curl_load("http://" + machinehash[1].to_s + ":3000/services/sysload")
       endlesswaltz << load if load
       load = curl_load("http://" + machinehash[2].to_s + ":3000/services/sysload")
       stevelaptop << load if load
    end
    url = "http://" + machinehash[rand(3)].to_s + ":3000/services/"  + servicehash[rand(4)].to_s
    name = url.match(/services\/(.+)/)[1]
    servicecount[name] += 1 
    puts "REQUESTING: " + url
    begin
       c = Curl::Easy.http_get(url) #TODO: change to http put with random parameters
       if c.body_str.include?("not available")
            error_urls << url
       else
          host = c.body_str.match(/http:\/\/(.+?):/)[1]
          host = `hostname`.strip if host.include?("localhost")
          request[host][name] += 1   #first index into hash is machine that served up the service
          # update the count of requests handled by service and given machine
          # count total # of service requests
          time += c.total_time
          success +=1
          puts "success"
          newurl = c.body_str.match(/http:\/\/.+?\/[A-Za-z]+/)[0]
          
          # http_put at the redirecte d urls
          pi_put(newurl) if name.include?("pi")
          quad_put(newurl) if name.include?("quad")
          convert_put(newurl) if name.include?("convert")
          fib_put(newurl) if name.include?("fib")           
  
  
      end
                         
    rescue Exception => e
       error_urls  << url  # perhaps track specific error as well, for now just track sites missed
    end
   
     sleep 5 
end

time = time/success


puts "Average response time: " + time.to_s
puts "Services Requested: " + servicecount.inspect
puts "Response breakdown: " + request.inspect


