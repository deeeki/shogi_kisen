# coding: utf-8
require File.expand_path('../boot', __FILE__)

LOG = File.expand_path('../log/latest.log', __FILE__)
IO.write(LOG, '2013-01-01') unless File.exist?(LOG)
latest = Date.parse(IO.read(LOG))

games_hash = JSA::Game.fetch_result

games_hash.sort.each do |date_str, games|
  date = Date.parse(date_str)
  next if date <= latest

  games.reject!{|g| g.black_winlose.empty? }
  games.each_with_index do |game, i|
    suffix = ''
    suffix << ' ' << JSA::Game::RESULT_URL if i == games.size - 1
    suffix << ' #shogi' if i.zero?
    tweet = %[#{date.strftime('%Y年%m月%d日')}の対局結果 【#{game.title}】 #{game.black_winlose}#{game.black_player} - #{game.white_player}#{game.white_winlose}#{suffix}]
    begin
      @client.update(tweet)
    rescue => e
      p game, tweet, e
      raise e unless e.message.include?('duplicate')
    end
    sleep(5)
  end
  IO.write(LOG, date_str)
  break
end
