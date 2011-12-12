# this will check the database to see if this service was recently down
# and brought back up.
# If this application was restarted quickly enough (set below) then
# you can cache the last saved state instead of discovering it

# in seconds
FRESH_FOR= 10 * 60

h = Service.last.state
if (Time.now - h['timestamp']) < FRESH_FOR
  puts "Starting with cache: " + Rails.cache.write(Service.cache_key, h).inspect
else
  puts "Starting without cache..."
end
