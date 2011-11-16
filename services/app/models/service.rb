require 'peach'
require 'net/http/persistent'
class Service < ActiveRecord::Base
  APPS = {
    'pi' => '3141',
    'fib' => '3001',
    'convert' => '1210',
    'quad' => '4416'
  }
  AVERAGE_LOAD = 5**10

  CACHE_KEY = 'discovered'

  serialize :state

  validates_presence_of :state

  #check local balance, checks if service can be run and load is below threshold else returns false
  def self.run_local(servicename, balance)
    load = net_get("http://localhost:#{Service::APPS[servicename]}/load")
    [load &&  (!balance || (load.to_f < Service::AVERAGE_LOAD )), load]
  end

  def self.min_load(shash, servicename, locallow=nil)  #TODO using peachi
    if locallow == nil || !locallow
        min = 10**20
    else
        min = locallow
    end
    shash[:services][servicename].each do |host|
      load  = net_get("http://#{host}:#{Service::APPS[name]}/load")
      if load < min
         min = load
         minhost = host
      end
    end
    return false if min == 10**20
    return "http://localhost:3000/services/#{servicename}" if locallow == min
    return "http://#{minhost}:3000/services/#{servicename}"
  end
  #TODO: fixed threshold for now, possibly dynamic later if time permits

  ##
  # returns a populated services object, generally for cacheing
  def self.discovery
    cache_me = {
      :services => Hash.new{ |hash,key| hash[key] = Array.new },
      :timestamp => nil
    }

    # remote call to services/list
    nmap.peach do |box|
      json_out = net_get("http://#{box}:3000/services/list")
      if json_out
        JSON.parse(json_out).peach do |name|
          cache_me[:services][name] << box
        end
      end
    end

    cache_me[:timestamp] = DateTime.now
    cache_me
  end

  def self.up?(name,host='localhost')
    if !net_get("http://#{host}:#{Service::APPS[name]}")
     return false
   else
    return true
    end
  end

  def self.cache_key
    CACHE_KEY
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
