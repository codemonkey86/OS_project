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
   
     
    nmap.peach do |box|
      APPS.keys.peach do |name|
        #TODO: instead of calling each service,  call each hosts services/list method?
           cache_me[:services][name] << box if Service.up?(name)
      end
    end
    
    cache_me[:timestamp] = DateTime.now
    cache_me
  end
  
  def self.up?(name,host='localhost')
    curb_me("http://#{host}:#{Service::APPS[name]}") == 200
  end
  
  private
  # Curb wrapper to catch any errors for connections
  # input: url to connect to
  # output: false on error or curb response otherwise
  # TODO: would need to give back obj eventually- return a tuple status (curb respose or false,  object (or nil in case of false))
  def self.curb_me(url)
    begin
      c = Curl::Easy.perform(url)
      c.response_code
    rescue Curl::Err::ConnectionFailedError
      return false
    end
  end

  #dummy cheat
  def self.nmap
    s = "localhost stevebox"
    [s.split(' ')[0]]
  end
end

