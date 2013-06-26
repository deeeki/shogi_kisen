# coding: utf-8
require File.expand_path('../boot', __FILE__)

LOG = File.expand_path('../log/latest_topic.log', __FILE__)
IO.write(LOG, '2013-01-01 00:00:00 UTC') unless File.exist?(LOG)
latest = Time.parse(IO.read(LOG))

exit unless JSA::Topic.latest_updated > latest

JSA::Topic.fetch.reverse.each do |topic|
  next if topic.updated <= latest

  action = (topic.published > latest) ? '公開' : '更新'
  type = topic.type ? "【#{topic.type}】 " : ''
  tweet = %[#{type}#{topic.title} #{topic.link} (#{topic.updated.strftime('%Y年%m月%d日')}#{action}) #shogi]
  begin
    Twitter.update(tweet)
  rescue => e
    raise e unless e.message == 'Status is a duplicate'
  end
  sleep(5)
end
IO.write(LOG, JSA::Topic.latest_updated)
