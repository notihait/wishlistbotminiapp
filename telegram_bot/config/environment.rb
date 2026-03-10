require 'bundler/setup'
Bundler.require

require 'dotenv'
Dotenv.load

require_relative '../lib/database'
require_relative '../lib/models/wishlist'
require_relative '../lib/models/user'

