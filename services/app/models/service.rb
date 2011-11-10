'require peach'
class Service < ActiveRecord::Base
  APPS = {
    'pi' => '3141',
    'fib' => '3001',
    'convert' => '1210',
    'quad' => '4416'
  }

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
    logger.info "http://#{host}:#{Service::APPS[name]}"
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
      res = Net::HTTP.get(URI.parse(url))
    rescue Exception => e
      false
    end
  end

  #dummy cheat
  def self.nmap
    %w(localhost stevebox)
  end
end

