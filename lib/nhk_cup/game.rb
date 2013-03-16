require 'ostruct'

module NHKCup
  class Game
    REPLAY_URL = 'http://cgi2.nhk.or.jp/goshogi/kifu/sgs.cgi'
    SCORE_URL = 'http://cgi2.nhk.or.jp/goshogi/kifu/score.cgi'
    AGENT = Mechanize.new

    class << self
      def latest
        AGENT.get(REPLAY_URL).at('body').attributes['onload'].value.scan(/\d+/).first rescue nil
      end

      def find date_str
        url = "#{SCORE_URL}?d=#{date_str}&t=s"
        info = open(url).read.split(";\r\n").take(10).drop(1).map do |row|
          key, value = row.split('=')
          value.gsub!(/\s/, '') if key.include?('Player')
          [key.downcase, CGI.unescape(value.to_s)]
        end
        OpenStruct.new(Hash[info])
      end
    end
  end
end
