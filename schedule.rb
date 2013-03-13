# coding: utf-8
require File.expand_path('../boot', __FILE__)

games_hash = JSA::Game.fetch_schedule

today = Time.now
games_hash.sort.each do |date_str, games|
  next unless date_str == today.strftime('%Y-%m-%d')

  games.each_with_index do |game, i|
    suffix = ''
    suffix << ' ' << JSA::Game::SCHEDULE_URL if i == games.size - 1
    suffix << ' #shogi' if i.zero?
    tweet = %[#{today.strftime('%Y年%m月%d日')}の対局予定 【#{game.title}】 #{game.black_player} - #{game.white_player}#{suffix}]
    begin
      Twitter.update(tweet)
    rescue => e
      p game, tweet
      raise e unless e.message == 'Status is a duplicate'
    end
    sleep(5)
  end
  break
end
