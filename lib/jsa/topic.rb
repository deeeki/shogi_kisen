# coding: utf-8
require 'open-uri'
require 'rss'

module JSA
  class Topic
    RESOURCE_URL = 'http://www.shogi.or.jp/topics/atom.xml'
    attr_accessor :title, :link, :id, :published, :updated, :summary, :author, :content, :updated, :categories

    class << self
      attr_reader :feed

      def get_feed
        @feed = open(RESOURCE_URL){|feed| RSS::Parser.parse(feed.read) }
      end

      def fetch
        get_feed unless @feed
        @feed.items.map{|entry| from_feed_entry(entry) }
      end

      def latest_updated
        get_feed unless @feed
        @feed.updated.content
      end

      def from_feed_entry entry
        new({
          title: entry.title.content,
          link: entry.link.href,
          id: entry.id.content,
          published: entry.published.content,
          updated: entry.updated.content,
          summary: entry.summary.content.strip,
          author: entry.author.name,
          categories: entry.categories.map{|c| c.term },
          content: entry.content.content.strip,
        })
      end
    end

    def initialize attrs = {}
      attrs.each do |key, value|
        send("#{key}=", value) if respond_to?(key)
      end
    end

    def type
      news? ? 'お知らせ' : event? ? 'イベント' : nil
    end

    def event?
      categories.include?('イベント')
    end

    def news?
      categories.include?('お知らせ')
    end
  end
end
