# coding: utf-8
require File.expand_path('../boot', __FILE__)

type = ARGV[0] || 'news'
LOG = File.expand_path("../log/#{type}", __FILE__)
IO.write(LOG, '') unless File.exist?(LOG)
latest_url = IO.read(LOG).chomp

items = JSA.const_get(type.capitalize).fetch_and_filter(url: latest_url).reverse
exit if items.empty?

items.each do |item|
  begin
    @client.update(item.to_tweet)
  rescue => e
    raise e unless e.message == 'Status is a duplicate'
  end
  sleep(5)
end

IO.write(LOG, items.last.url)
