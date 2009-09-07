
$: << "../lib"

require 'sbiclient'
require 'constants'

# ログイン
c = SBIClient::Client.new
c.fx_session( USER, PASS ) {|session|
  
  # レート一覧を取得
  rates = session.list_rates
  rates.each_pair {|k,v|
    puts "#{k} : #{v.bid_rate} : #{v.ask_rate} : #{v.sell_swap} : #{v.buy_swap}"
  }
}
