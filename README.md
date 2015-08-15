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
      - cameron: satan
    save_file: /Users/sam/.replacer_bot/last.tweet

You'll also need some Twitter credentials, store them in 
