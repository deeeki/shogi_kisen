# coding: utf-8
module JSA
  class Game
    GAME_URL = 'http://www.shogi.or.jp/game/'
    SCHEDULE_URL = 'http://www.shogi.or.jp/game/schedule/'
    RESULT_URL = 'http://www.shogi.or.jp/game/result/'
    SCHEDULE_HTML_CLASS = 'tableElements03'
    RESULT_HTML_CLASS = 'tableElements01'

    attr_accessor :title, :draw, :black_winlose, :black_player, :white_winlose, :white_player, :place, :remark

    @html_class = SCHEDULE_HTML_CLASS
    @row_conversion_method = :from_schedule_row

    class << self
      attr_accessor :html_class, :row_conversion_method

      def fetch_schedule
        @html_class = SCHEDULE_HTML_CLASS
        @row_conversion_method = :from_schedule_row
        fetch(GAME_URL)
      end

      def fetch_result
        @html_class = RESULT_HTML_CLASS
        @row_conversion_method = :from_result_row
        fetch(GAME_URL)
      end

      def fetch url
        games = {}
        date = Date.today
        page = AGENT.get(url)
        page.search("table.#{@html_class} tr").each do |tr|
          if /備考/ =~ tr.text
            next
          elsif /(?<month>\d+)月(?<first>[\d]+)・(?<second>[\d]+)日/ =~ tr.text
            year = (month.to_i == 12 && date.month == 1) ? date.year - 1 : date.year
            @date = "#{year}-#{format('%02d', month)}-#{format('%02d', first)}"
            @date2 = "#{year}-#{format('%02d', month)}-#{format('%02d', second)}"
          elsif /(?<month>\d+)月(?<day>\d+)日/ =~ tr.text
            year = (month.to_i == 12 && date.month == 1) ? date.year - 1 : date.year
            @date = "#{year}-#{format('%02d', month)}-#{format('%02d', day)}"
            @date2 = nil
          else
            game = send(@row_conversion_method, tr.children.map{|td| td.text })
            games[@date] << game
            games[@date2] << game if @date2
          end
          games[@date] ||= []
          games[@date2] ||= [] if @date2
        end
        games
      end

      def from_schedule_row row = []
        new({
          title: row[0].gsub(/[　\s]+/, ''),
          black_player: row[1].gsub(/[　\s]+/, ''),
          white_player: row[2].gsub(/[　\s]+/, ''),
          place: row[3].gsub(/\A[　\s]+\z/, ''),
          remark: row[4].gsub(/\A[　\s]+\z/, ''),
        })
      end

      def from_result_row row = []
        if md = row[0].match(/[\s|・](千日手|持将棋)/)
          title = row[0].gsub(md[0], '').gsub(/[　\s]+/, '')
          draw = md[1]
        else
          title = row[0].gsub(/[　\s]+/, '')
          draw = nil
        end
        new({
          title: title,
          draw: draw,
          black_winlose: row[1].gsub(/[　\s]+/, ''),
          black_player: row[2].gsub(/[　\s]+/, ''),
          white_winlose: row[4].gsub(/[　\s]+/, ''),
          white_player: row[3].gsub(/[　\s]+/, ''),
          remark: row[5].gsub(/\A[　\s]+\z/, ''),
        })
      end
    end

    def initialize attrs = {}
      attrs.each do |key, value|
        send("#{key}=", value) if respond_to?(key)
      end
    end
  end
end
