require 'bundler/setup'
Bundler.require(:default) if defined?(Bundler)

$:.unshift(File.expand_path('../lib', __FILE__))
require 'jsa'
require 'nhk_cup'

Dotenv.load

@client = Twitter::REST::Client.new do |config|
  config.consumer_key = ENV['TWITTER_CONSUMER_KEY']
  config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
  config.access_token = ENV['TWITTER_ACCESS_TOKEN']
  config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
end
