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
  title = topic.title
  title_max_length = 140 - type.size - 23 - 11 - 2 - 6 - 5 # link/date/action/hashtag/etc
  title = title[0, title_max_length - 4] + ' ...' if title.size > title_max_length
  tweet = %[#{type}#{title} #{topic.link} (#{topic.updated.strftime('%Y年%m月%d日')}#{action}) #shogi]
  begin
    Twitter.update(tweet)
  rescue => e
    raise e unless e.message == 'Status is a duplicate'
  end
  sleep(5)
end
IO.write(LOG, JSA::Topic.latest_updated)
