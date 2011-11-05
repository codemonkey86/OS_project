# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_pi_session',
  :secret      => '1218d271bb2d4a8c7d62d19484f5752df9c3a8496477f7a593811116908f2bca2aaa059f6d59ecc3568a4653ea1096b37b469551be172a32be9b0d8c1789e9e3'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
