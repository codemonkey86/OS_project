# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_fib_session',
  :secret      => 'eec6db6afc54b6df911aa4dc35608ff543880db9a9e45a2368d33d6065642454d59938955b676c4cc92dda028f4a4bd15a26fb62bd2856bebcfd20dabf1cb8fb'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
