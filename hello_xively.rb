require 'cuba'
require 'mini_mqtt'
require 'ohm'

Ohm.redis = Redic.new ENV['REDIS_URL']

class Message < Ohm::Model
  attribute :body
end

Thread.new do
  puts 'initializing mqtt'
  client = MiniMqtt.new host: ENV['XIVELY_URL']
  client.connect do
    client.subscribe 'sample'
    client.get do |t, m|
      puts t, m
      Message.create body: m
    end
  end
end

Cuba.define do
  on get do
    on "hello" do
      presented_messages = Message.all.to_a.last(10).map do |m|
        "<li>#{ m.body }</li>"
      end.join("\n  ")
      res.write <<-HTML.gsub!(/^\s*\|/, '')
      | <h1>Hello xively!</h1>
      | <ol>
      |   #{ presented_messages }
      | </ol>
      HTML
    end

    on root do
      res.redirect "/hello"
    end
  end
end
