# this will check the database to see if this service was recently down
# and brought back up.
# If this application was restarted quickly enough (set below) then
# you can cache the last saved state instead of discovering it

# in seconds
FRESH_FOR= 10 * 60

def after_initialize
  h = Service.last.state
  if (Time.now - h[:timestamp]) < FRESH_FOR
    Rails.cache.write(Service.cache_key, h)
  else
    Service.create(:state=>Rails.cache.write(Service.cache_key,Service.discovery))
  end
end
