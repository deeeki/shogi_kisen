# coding: utf-8

module JSA
  class Article
    attr_accessor :title, :url, :date

    class << self
      attr_accessor :type

      def fetch
        @items ||= AGENT.get(@url).search('ul.listElementA01-10 > li > a').map do |a|
          updated_str = a.at('small').text
          new({
            title: a.text.gsub(updated_str, ''),
            url: a[:href],
            date: updated_str,
          })
        end
      end

      def fetch_and_filter url: nil
        fetch
        index = @items.find_index{|i| i.url == url }
        index ? @items.slice(0, index) : @items
      end
    end

    def initialize attrs = {}
      attrs.each do |key, value|
        send("#{key}=", value) if respond_to?(key)
      end
    end

    def to_tweet
      title = @title
      title_max_length = 140 - self.class.type.size - 2 - 23 - @date.size - 6 - 3 # type-bracket-url-date-hashtag-spaces
      title = title[-1, title_max_length - 4] + ' ...' if title.size > title_max_length
      %[【#{self.class.type}】#{title} #{@url} #{@date} #shogi]
    end
  end

  class News < Article
    @url = 'http://www.shogi.or.jp/news/'
    @type = 'ニュース'
  end

  class Event < Article
    @url = 'http://www.shogi.or.jp/event/'
    @type = 'イベント'
  end

  class Column < Article
    @url = 'http://www.shogi.or.jp/column/'
    @type = 'コラム'

    class << self
      def fetch
        @items ||= AGENT.get(@url).search('div.text.mb20').map do |d|
          a = d.at('p.ttl > em > a')
          new({
            title: a.text,
            url: a[:href],
            date: d.at('p.date').text.gsub("\t", ' ').strip,
          })
        end
      end
    end
  end
end
