# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_services_session',
  :secret      => 'f7b14fe0f2da9c1e518719342022d6e6810536ea560794721c05ba15b9ccbfc0d803092b360962ac2a9f42d825129db4963f0071f92d12bf38f9c7bf2b75b199'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
