# coding: utf-8
require File.expand_path('../boot', __FILE__)

LOG = File.expand_path('../log/latest_topic.log', __FILE__)
IO.write(LOG, '2013-01-01 00:00:00 UTC') unless File.exist?(LOG)
latest = Time.parse(IO.read(LOG))

exit unless JSA::Topic.latest_updated > latest

JSA::Topic.fetch.each do |topic|
    next if topic.updated <= latest

    tweet = %[【#{topic.type}】 #{topic.title} #{topic.link} (#{topic.published.strftime('%Y年%m月%d日')}) #shogi]
    Twitter.update(tweet)
    sleep(5)
end
IO.write(LOG, JSA::Topic.latest_updated)
