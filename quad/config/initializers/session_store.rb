# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_quad_session',
  :secret      => '29ed9ee14e08c386fe35571399bcb164c5cc5e281b96b11b2a282d1c0edfdbcdf859a3948adf7e893be25d2e3ee148e6b447cefce5795ab284e6be4712b8a9d7'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
