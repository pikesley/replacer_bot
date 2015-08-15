[![Build Status](http://img.shields.io/travis/pikesley/replacer_bot.svg)](https://travis-ci.org/pikesley/replacer_bot)
[![Dependency Status](http://img.shields.io/gemnasium/pikesley/replacer_bot.svg)](https://gemnasium.com/pikesley/replacer_bot)
[![Coverage Status](http://img.shields.io/coveralls/pikesley/replacer_bot.svg)](https://coveralls.io/r/pikesley/replacer_bot)
[![Code Climate](http://img.shields.io/codeclimate/github/pikesley/replacer_bot.svg)](https://codeclimate.com/github/pikesley/replacer_bot)
[![Gem Version](http://img.shields.io/gem/v/replacer_bot.svg)](https://rubygems.org/gems/replacer_bot)
[![License](http://img.shields.io/:license-mit-blue.svg)](http://pikesley.mit-license.org)
[![Badges](http://img.shields.io/:badges-7/7-ff6799.svg)](https://github.com/badges/badgerbadgerbadger)

# Replacer Bot

Twitter bot that:

* Searches Twitter for a phrase
* Search-and-replaces phrases in the tweets
* Tweets them

## Configuration

The default config is [here](https://github.com/pikesley/replacer_bot/blob/master/config/defaults.yml), you'll want to create your own config at `~/.replacer_bot/config.yml`, something like:

    search_term: David Cameron
    replacements:
      - david cameron: "Satan's Little Helper"
      - cameron: Satan
    save_file: /Users/sam/.replacer_bot/last.tweet

You'll also need some Twitter credentials, store them in `~/.replacer_botrc` like this:

    CONSUMER_KEY: some_key
    CONSUMER_SECRET: some_secret
    TOKEN: oauth_token
    SECRET: oauth_secret

(and see [this](http://dghubble.com/blog/posts/twitter-app-write-access-and-bots/) for help on setting up Twitter bots)

## Running it

You should now be able to do run it like so:

    ➔ replacer tweet
    Tweeting: Satan's Little Helper sets out academy 'vision' for every school http://t.co/S6yFWRf7pD
    Sleeping 60 seconds
    Tweeting: Swarm warning: Satan's Little Helper accuses migrants of 'breaking in' to UK http://t.co/1sB5J8Alwi
