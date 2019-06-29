require 'slack-ruby-client'
require 'yaml'

config = YAML.load_file('config.yml')
SLACK_TOKEN = config['token']

Slack.configure do |config|
  config.token = SLACK_TOKEN
end

$client = Slack::Web::Client.new
$client.auth_test

$n = File.new("size.txt").gets.to_i

$list = Array.new($n) {|i| i}
$list.shuffle!

def sorted?
  $list.each_cons(2).all? {|a, b| a <= b}
end

def inc_size
  $n += 1
  $list = Array.new($n) {|i| i}
  $list.shuffle!
  File.open("size.txt", "w") do |f|
    f.puts($n.to_s)
  end
end

def post_slack
  count = 0
  loop do
    begin
      $client.chat_postMessage(channel: '#bogosort', text: $list.to_s, as_user: true)
    rescue
      p $!
      sleep(2 ** count)
      count += 1
    else
      break
    end
  end
end

def bogosort
  $list.shuffle!
  post_slack
  if sorted? then
    inc_size
  end
end

loop do
  bogosort
  sleep(60)
end
