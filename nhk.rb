# coding: utf-8
require File.expand_path('../boot', __FILE__)

LOG = File.expand_path('../log/nhk_latest.log', __FILE__)
File.write(LOG, '20130101') unless File.exist?(LOG)
latest = File.read(LOG)

date_str = NHKCup::Game.latest
exit unless latest < date_str

game = NHKCup::Game.find(date_str)

game_str = "[#{game.stage}] #{game.player1} - #{game.player2} (#{game.onair})"
tweet = %[【NHK杯】棋譜が更新されました #{game_str} #{NHKCup::Game::REPLAY_URL}?#{date_str}&t=s]

begin
  Twitter.update(tweet)
rescue => e
  p game, tweet
  raise e
end

File.write(LOG, date_str)
