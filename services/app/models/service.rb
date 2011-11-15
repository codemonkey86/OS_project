require 'peach'
require 'net/http/persistent'
class Service < ActiveRecord::Base
  
 #TODO: policies to be populated from reading XML
  APPS = {
    'pi' => ['3141', 'pipoolicy'],
    'fib' => ['3001','fibpolicy'],
    'convert' => ['1210', 'convertpolicy'],
    'quad' => ['4416', 'quadpolicy']
  }

  
  #check local balance, checks if service can be run and load is below threshold else returns false 
  def self.run_local(servicename, policies)     
    load = net_get("http://localhost:#{Service::APPS[servicename].first}/load")
    load &&  (load.to_f < Service::AVERAGE_LOAD )
  end
 
  def self.min_load(shash, servicename, locallow=nil)  #TODO using peachi
      if locallow == nil || !locallow
          min = 10**20 
      else 
          min = locallow
     end
      shash[:services][servicename].each do |host|
         load  = net_get("http://#{host}:#{Service::APPS[name].first}/load") 
         if load < min
             min = load
             minhost = host
         end
      end
      return false if min == 10**20
      return "http://localhost:3000/services/#{servicename}" if locallow == min
      return "http://#{minhost}:3000/services/#{servicename}"
 
                 


  end




  ##
  # returns a populated services object, generally for cacheing
  def self.discovery  #TODO: needs to be tested for newly designed hash

   cache_me = {
      :timestamp => nil,
      :machinepolicy => nil,
      :services => Hash.new{ |hash,key| hash[key] =  {
                                          :policies => nil,
                                          :hosts => Array.new,
                                           :threshold => nil
                                          }
                  }
   }
   serviceload = Hash.new(0)
    # remote call to services/list  
    nmap.peach do |box|
      json_out = net_get("http://#{box}:3000/services/list")  
      #json should be array of (servicename, policy) tuples
      
      if json_out
        JSON.parse(json_out).peach do |namepolicy|
          cache_me[:services][namepolicy.first][:hosts] << box
          cache_me[:services][namepolicy.first][:policies] = namepolicy.last      
          load = 
          serviceload[namepolicy.first] = serviceload[namepolicy.first] + (net_get("http://#{box}:#{Service::APPS[namepolicy.first].first}/load").to_f || 0)
        end
       
        
      end
    end
   # cache_me[:services][servicename][threshold] = avg
   cache_me[:services].keys.peach do |sname|
         cache_me[:services][sname][:threshold]  =  serviceload[sname]/cache_me[:services][sname][:hosts].size
   end
    cache_me[:timestamp] = DateTime.now
    #cache_me[:machinepolicy] = ???
    cache_me

  end

  def self.up?(name,host='localhost')
    if !net_get("http://#{host}:#{Service::APPS[name]}")  
     return false
   else 
    return true
    end
  end

  private
  # wrapper to catch any errors for connections
  # input: url to connect to
  # output: false on error or curb response otherwise
  # TODO: would need to give back obj eventually- return a tuple status (curb respose or false,  object (or nil in case of false))
  def self.net_get(url)
    begin
      res = Net::HTTP::Persistent.new.request URI url
      res.body 
    rescue Exception => e 
      false
    end
  end

  #dummy cheat
  def self.nmap
    %w(localhost stevebox)
  end

  

  def self.up?(name,host='localhost')
    if !net_get("http://#{host}:#{Service::APPS[name].first}")  
     return false
   else 
    return true
    end
  end

  private
  # wrapper to catch any errors for connections
  # input: url to connect to
  # output: false on error or curb response otherwise
  # TODO: would need to give back obj eventually- return a tuple status (curb respose or false,  object (or nil in case of false))
  def self.net_get(url)
    begin
      res = Net::HTTP::Persistent.new.request URI url
      res.body 
    rescue Exception => e 
      false
    end
  end

  #dummy cheat
  def self.nmap
    %w(localhost stevebox)
  end
end
