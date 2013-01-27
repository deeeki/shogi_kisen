# coding: utf-8
module JSA
  class Game
    SCHEDULE_URL = 'http://www.shogi.or.jp/kisen/week/yotei.html'
    RESULT_URL = 'http://www.shogi.or.jp/kisen/week/kekka.html'
    AGENT = Mechanize.new
    attr_accessor :title, :black_winlose, :black_player, :white_winlose, :white_player, :remark, :place

    class << self
      def fetch_schedule
        fetch(SCHEDULE_URL)
      end

      def fetch_result
        fetch(RESULT_URL)
      end

      def fetch url
        games = {}
        now = Time.now
        page = AGENT.get(url)
        page.search('#schedule table tr').each do |tr|
          if /備考/ =~ tr.text
            next
          elsif /(?<month>\d+)月(?<first>[\d]+)・(?<second>[\d]+)日/ =~ tr.text
            year = (month.to_i == 12 && now.month == 1) ? now.year - 1 : now.year
            @date = "#{year}-#{format('%02d', month)}-#{format('%02d', first)}"
            @date2 = "#{year}-#{format('%02d', month)}-#{format('%02d', second)}"
          elsif /(?<month>\d+)月(?<day>\d+)日/ =~ tr.text
            year = (month.to_i == 12 && now.month == 1) ? now.year - 1 : now.year
            @date = "#{year}-#{format('%02d', month)}-#{format('%02d', day)}"
            @date2 = nil
          else
            game = from_row(tr.children.map{|td| td.text })
            games[@date] << game
            games[@date2] << game if @date2
          end
          games[@date] ||= []
          games[@date2] ||= [] if @date2
        end
        games
      end

      def from_row row = []
        new({
          title: row[4],
          black_winlose: row[0],
          black_player: row[1].gsub(/　/, ''),
          white_winlose: row[3],
          white_player: row[2].gsub(/　/, ''),
          remark: row[5],
          place: row[6]
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
