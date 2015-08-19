require 'twitter'
require 'dotenv'
require 'uri'
require 'singleton'
require 'thor'
require 'yaml'
require 'htmlentities'

require 'replacer_bot/version'
require 'replacer_bot/replacer'
require 'replacer_bot/config'
require 'replacer_bot/helpers'
require 'replacer_bot/seen_tweets'
require 'replacer_bot/twitter_client'

Dotenv.load
Dotenv.load "#{ENV['HOME']}/.replacer_botrc"

TWITTER_LIMIT= 140
