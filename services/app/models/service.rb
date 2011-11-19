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
  CACHE_KEY = 'discovered'

  serialize :state

  validates_presence_of :state

  #check local balance, checks if service can be run and load is below threshold else returns false
  def self.run_local(servicename, servicepolicy, machinepolicy, threshold)
    load = net_get("http://localhost:#{Service::APPS[servicename].first}/load")
    load &&  (load.to_f < threshold)  && policymatch(servicepolicy,machinepolicy)
  end

  def self.minload(scache, policyreq, port)  # find machine that is up with absolute minimum load and appropriate policy 
                                     #(make sure it is up before assigning it as "low", tkaen care of indirectly by checking balance
      low = 10**100
      host = nil
      if !scache[:host_policy].empty?
        scache[:host_policy].keys.peach do |hostkey|
          load = Service.net_get("http://#{hostkey}:#{port}/load")
          puts "load" + load.to_s + "low" + low.to_s
          if load && (load.to_f < low) && self.policymatch(scache[:host_policy][hostkey], policyreq) 
              low = load.to_f
             
              host = hostkey
          end
        end
      end
      host = "http://#{host}:#{port}"   if host          
       
  end

  def self.policymatch(ptest, preq)     #parse boolean logic
   
     
     
     true  #for now, need to implement      
    
                 
  end
  
  def self.getindex
    Rails.cache.read(Service.cache_key)
  end
  
  
  def self.getlist
    
    s = []
     if !Service::APPS.keys.empty?
       Service::APPS.keys.peach do |namepolicy| 
         s << [namepolicy, Service::APPS[namepolicy].last] if Service.up?(namepolicy)
       end
     end
    
     s
     # render :json => s  model equivalent to this?
  end
  
  ##
  # returns a populated services object, generally for cacheing
  def self.discovery  #TODO: needs to be tested for newly designed hash
   cache_me = {
      :timestamp => nil,
      :machinepolicy => nil,
   :services =>  Hash.new {|hash,key|
                      hash[key] = {:host_policy => Hash.new{|hash,key|
                                    hash[key] = nil},
                                   :threshold => nil}
                     }

   }
 
   serviceload = Hash.new(0)
    # remote call to services/list
    if !nmap.empty?
      nmap.peach do |box|
        json_out = net_get("http://#{box}:3000/services/list") || "[]"
        #json should be array of (servicename, policy) tuples
        if !JSON.parse(json_out).empty?
          JSON.parse(json_out).peach do |namepolicy|
            cache_me[:services][namepolicy.first][:host_policy][box] = namepolicy.last
            serviceload[namepolicy.first] = serviceload[namepolicy.first] + (net_get("http://#{box}:#{Service::APPS[namepolicy.first].first}/load").to_f || 0)
          end
        end
       end
    end
  
   if !cache_me[:services].keys.empty?
      cache_me[:services].keys.peach do |sname| 
         cache_me[:services][sname][:threshold]  =  serviceload[sname]/cache_me[:services][sname][:host_policy].keys.size
       end
    end
    cache_me[:timestamp] = DateTime.now
    cache_me

  end

  def self.up?(name,host='localhost')
    if !net_get("http://#{host}:#{Service::APPS[name].first}")
     return false
   else
    return true
    end
  end

  def self.cache_key
    CACHE_KEY
  end

  # TODO: eventually kick this off periodically somehow, script/runner ?
  ##
  # This will get all the other box's views of the network and compare
  # them to peach other to determine who has the newest overview
  # which will be sent back to everyone
  #TODO, don't return to winner
  def sync
    caches = []
    return if nmap.empty?
      nmap.peach do |box| 
        resp = net_get("http://#{box}:3000")
        caches << JSON.parse(resp) if resp
      end
   
    newest = caches.sort{|a,b| a[:timestamp] <=> b[:timestamp]}.last

    # do a post to services/set_cache
    post = Net::HTTP::Post.new 'services'
    post.set_form_data 'newest' => newest

    # perform the POST, the URI is always required
    nmap.peach do |box| 
      post_uri = URI "http://#{box}:3000/set_cache"
      Net::HTTP::Persistent.new.request post_uri, post
    end
  end

  private
  # wrapper to catch any errors for connections
  # input: url to connect to
  # output: false on error or curb response otherwise
  # TODO: would need to give back obj eventually- return a tuple status (curb respose or false,  object (or nil in case of false))
  #problem: hangs on localhost:3000, only needed for services/list and get cache?
  def self.net_get(url)
    if url.include?("#{`hostname`.strip}")  && url.include?(":3000") && url.include?("list")
        return self.getlist.to_json
    end
    
    if url.include?("#{`hostname`.strip}") && url.include?(":3000")
         return self.index.to_json
    end
    
    
    begin
      res = Net::HTTP::Persistent.new.request URI url
      res.body
    rescue Exception => e
      false
    end
  end

  #dummy cheat
  def self.nmap
    %w(master steve-laptop)
  end
end
