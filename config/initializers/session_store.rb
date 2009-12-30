# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_skillz_session',
  :secret      => '5ccac1b53fa676054ce91c133790dc3e1b101ae6384b57d8046d2ee9abe95af82558a6987232b6a3fd5b7212f596051fc90185f3e4601da1962d8da82e01cf46'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
