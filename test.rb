require 'rspec'
require_relative 'market_trades_script'

describe MarketTradesScript, '.fetch_markets' do
  let(:market_instance) { MarketTradesScript.new }

  it 'Total number of markets' do
    total_markets = market_instance.fetch_markets
    expect(total_markets.count).to be(19)
  end
  it 'If it brings the markets' do
    @response = HTTParty.get('https://www.buda.com/api/v2/markets')
    expect(@response.parsed_response).to include('markets')
  end
  it 'If there are no trades in a market' do
    market_id = market_instance.fetch_markets[0]['id']
    today = DateTime.now.to_time.to_i * 1000
    trades = market_instance.fetch_trades(market_id, today)
    expect(trades.empty?).to eq(false)
  end
  it 'it return the correct question' do
    market_names = market_instance.fetch_markets.map.with_index { |market, index| "#{index}.- #{market['name']}\n" }
    market_names.each do |name|
      expect { market_instance.select_market }.to output(/#{name}/).to_stdout
    end
    expect { market_instance.select_market }.to output(/Escriba el número del mercado\n/).to_stdout
  end
end
