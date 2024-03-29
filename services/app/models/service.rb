# This is our primary model for the project.  Arguably the most important method is in here: discovery
# this method is called on cache miss, and is where we establish what the hash containing service information looks like
# it also contains helper methods (run_local and min_load) for load balancing

require 'peach'
require 'net/http/persistent'
class Service < ActiveRecord::Base

 #TODO: policies to be populated from reading XML
  APPS = {
    'pi' => '3141',
    'fib' => '3001',
    'convert' => '1210',
    'quad' => '4416'
  }

  @@LOADS = {
     'pi' => 0,
     'fib' => 0,
     'convert' => 0,
     'quad' => 0
  }

  LOAD_PCT = 0.25

  CACHE_KEY = 'discovered'

  serialize :state

  validates_presence_of :state

  #check local balance, checks if service can be run and load is below threshold else returns false
  def self.run_local(servicename, servicepolicy, req_pol)
    load = net_get("http://localhost:#{Service::APPS[servicename]}/load")
    if load
       load = load.to_f
    else
        return false
    end

    threshold = @@LOADS[servicename]
    if load < @@LOADS[servicename] && load/@@LOADS[servicename] > LOAD_PCT
         @@LOADS[servicename] = (load + @@LOADS[servicename])/2
    end
    if @@LOADS[servicename] < load && @@LOADS[servicename]/load > Service::LOAD_PCT
          @@LOADS[servicename] = (load + @@LOADS[servicename])/2
    end
     load && (load < threshold) && Policy.can_talk?(servicepolicy,req_pol)
  end

  # find machine that is up with absolute minimum load and appropriate policy
  def self.minload(scache, req_pol, port)
    # make sure it is up before assigning it as "low"
    # taken care of indirectly by checking balance
    low = 10**100
    host = nil
    if !scache['host_policy'].empty?
      scache['host_policy'].keys.each do |hostkey|
        load = Service.net_get("http://#{hostkey}:#{port}/load")
         if load && (load.to_f < low) && Policy.can_talk?(scache['host_policy'][hostkey],req_pol)
          low = load.to_f
          host = hostkey
        end
      end
    end
    host = "http://#{host}:#{port}" if host
  end

  def self.getindex
    cache = Rails.cache.read(Service.cache_key) || {}
    puts 'LIST CACHE ' + cache.inspect
    return cache if cache.empty?
    @@LOADS.keys.peach do |name|
        next unless cache['services'][name]
         @@LOADS[name] = cache['services'][name]['threshold']
    end
    cache
  end

  def self.getlist
    s = []
    puts "Test start"
    unless Service::APPS.keys.empty?
      puts "test end"
      Service::APPS.keys.each do |namepolicy|
        xml = get_policies(namepolicy)
        s << [namepolicy, Policy.new(xml)] if xml
        puts "TESTING" + Policy.new(xml).inspect if xml
      end
    end
    s
  end

  ##
  # returns a populated services object, generally for cacheing
  def self.discovery
    #outer index is either timestamp, machine policy or services
    #inner service hash maps threshold and array of host_policy tuples to a service
    cache_me = {
      'timestamp' => nil,
      'services' =>  Hash.new {|h,k|
        h[k] = {'host_policy' => Hash.new{|hash,key|
        hash[key] = nil},
        'threshold' => nil}
      }
    }


    serviceload = Hash.new(0)
    # remote call to services/list
    if !nmap.empty?
      nmap.peach do |box|
        json_out = net_get("http://#{box}:3000/services/list") || "[]"
        #json should be array of (servicename, policy) tuples
        puts "TESTING" + json_out + box
        if !JSON.parse(json_out).empty?
          JSON.parse(json_out).peach do |namepolicy|
            cache_me['services'][namepolicy.first]['host_policy'][box] = namepolicy.last
              serviceload[namepolicy.first] +=
              (net_get("http://#{box}:#{Service::APPS[namepolicy.first]}/load").to_f || 0)
          end
        end
      end
    end

    puts cache_me['services']
   if !cache_me['services'].keys.empty?
      cache_me['services'].keys.peach do |sname|
         cache_me['services'][sname]['threshold']  =  serviceload[sname]/cache_me['services'][sname]['host_policy'].keys.size
         @@LOADS[sname] = cache_me['services'][sname]['threshold']
      end
   end


    cache_me['timestamp'] = DateTime.now
    cache_me
  end

  ##
  # attempts to get policies from another service
  def self.get_policies(name)
    net_get("http://localhost:#{Service::APPS[name]}/policy")
  end

  def self.cache_key
    CACHE_KEY
  end

  private
  # wrapper to catch any errors for connections
  # input: url to connect to
  # output: false on error or curb response otherwise

  def self.net_get(url)
    if url.include?("#{`hostname`.strip}")  && url.include?(":3000")
      if url.include?("list")
        return self.getlist.to_json
      else
        return self.getindex.to_json
      end
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
    %w(endlesswaltz Computitron master endlessjig)
  end
end
