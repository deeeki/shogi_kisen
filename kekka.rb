# coding: utf-8
require File.expand_path('../boot', __FILE__)

RESOURCE_URL = 'http://www.shogi.or.jp/kisen/week/kekka.html'
@rubytter = OAuthRubytter.new(@access_token)

log_file = 'log/latest.log'
File.open(log_file, 'w') {|f| f.puts '2011-01-01'} unless File.exist?(log_file)
latest = IO.read(log_file)
@latest = Time.gm *latest.split('-')

if @latest > Time.now - 86400
	exit
end

@games = {}
agent = Mechanize.new
agent.get(RESOURCE_URL)
agent.page.root.search('table.kisen')[0].children.each do |tr|
	if /備考/ =~ tr.text
	elsif /(?<month>\d+)月(?<first>[\d]+)・(?<second>[\d]+)日/ =~ tr.text
		@date = Time.now.year.to_s + '-' + format('%02d', month) + '-' + format('%02d', first)
		@date2 = Time.now.year.to_s + '-' + format('%02d', month) + '-' + format('%02d', second)
		if !@games[@date]
			@games[@date] = []
		end
		if !@games[@date2]
			@games[@date2] = []
		end
	elsif /(?<month>\d+)月(?<day>\d+)日/ =~ tr.text
		now = Time.now
		if now.month == 12 && month == 1
			now = Time.local(now.year - 1)
		end
		@date = now.year.to_s + '-' + format('%02d', month) + '-' + format('%02d', day)
		@date2 = nil
		if !@games[@date]
			@games[@date] = []
		end
	else
		cols = []
		tr.children.each do |td|
			cols << td.text
		end
		row = {
			title: cols[4],
			black: cols[0],
			black_name: cols[1].gsub(/　/, ''),
			white: cols[3],
			white_name: cols[2].gsub(/　/, ''),
			other: cols[5],
			place: cols[6]
		}
		@games[@date] << row
		if @date2 != nil
			@games[@date2] << row
		end
	end
end

@games.sort.each do |date, games|
	target = Time.gm *date.split('-')
	next if target <= @latest

	games.each_with_index do |game, i|
		next unless /[○●]+/ =~ game[:black]

		suffix = ''
		if i == games.size - 1
			suffix += ' ' + RESOURCE_URL
		end
		if i == 0
			suffix += ' #shogi'
		end
		tweet = target.strftime('%Y年%m月%d日') + 'の対局結果' + ' 【' + game[:title] + '】 ' + game[:black] + game[:black_name] + ' - ' + game[:white_name] + game[:white] + suffix
		@rubytter.update(tweet)
		sleep(5)
	end
	File.open(log_file,'w') {|file| file.puts target.strftime('%Y-%m-%d')}
	puts 'target:' + target.to_s
	break
end
puts Time.now.to_s + ' process finish.'
