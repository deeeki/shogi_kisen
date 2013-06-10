# coding: utf-8
require File.expand_path('../boot', __FILE__)

LOG = File.expand_path('../log/nhk_latest.log', __FILE__)
File.write(LOG, '20130101') unless File.exist?(LOG)
latest = File.read(LOG)

date_str = NHKCup::Game.latest_date_str
exit unless latest < date_str

game = NHKCup::Game.find(date_str)

onair_str = "(#{Date.parse(game.onair).strftime('%Y年%m月%d日')}放送分)"
game_str = "[#{game.title.delete('NHK杯')} #{game.stage}] #{game.player1} - #{game.player2}"
tweet = %[【NHK杯】棋譜更新 #{game_str} #{NHKCup::Game::REPLAY_URL}?#{date_str}&t=s #{onair_str} #shogi]

begin
  Twitter.update(tweet)
rescue => e
  p game, tweet
  raise e
end

File.write(LOG, date_str)
