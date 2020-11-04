require 'HTTParty'

class MarketTradesScript
  attr_reader :today, :yesterday, :market_index

  def initialize
    @markets = fetch_markets
    @today = DateTime.now.to_time.to_i * 1000
    @yesterday = (DateTime.now - 1).to_time.to_i * 1000
    @entries = []
  end

  def select_market
    market_names = @markets.map.with_index do |market, index|
      "#{index}.- #{market['name']}"
    end
    puts market_names
    puts 'Escriba el número del mercado'
    response = gets.chomp.to_i
    until (0..(@markets.length - 1)).include?(response)
      puts 'Ingrese un número valido'
      response = gets.chomp.to_i
    end
    @market_index = response
  end

  def fetch_markets
    HTTParty.get('https://www.buda.com/api/v2/markets').parsed_response['markets']
  rescue SocketError
    abort('Comprueba tu conexión a internet')
  end

  def fetch_trades(market_id, timestamp)
    HTTParty
      .get("https://www.buda.com/api/v2/markets/#{market_id}/trades?timestamp=#{timestamp}&limit=100")
      .parsed_response['trades']
  rescue SocketError
    abort('Comprueba tu conexión a internet')
  end

  def format_trades(trades)
    trades['entries'].map { |entrie| entrie[1] }
  end

  def run
    trades = fetch_trades(@markets[market_index]['id'], today)
    @entries.push(format_trades(trades))
    timestamp = trades['last_timestamp']
    while (yesterday..today).include?(timestamp.to_i)
      trades = fetch_trades(@markets[market_index]['id'], trades['last_timestamp'])
      @entries.push(format_trades(trades))
      break if timestamp == trades['last_timestamp']

      timestamp = trades['last_timestamp']
    end
    puts '-----'
    puts "Mayor monto #{@entries.flatten.max} #{@markets[market_index]['id'].split('-')[0]}"
    puts '-----'
    puts 'Si quiere salir escriba exit si no escriba cualquier cosa'
    command_break = gets.chomp
    puts '-----'
    return if command_break == 'exit'
    @entries = []
    select_market
    run
  end
end

