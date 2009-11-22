
$: << "../lib"

require 'sbiclient'
require 'common'

# ログイン
c = SBIClient::Client.new
c.fx_session( USER, PASS, ORDER_PASS ) {|session|

  # レートを取得
  rates = session.list_rates
  rates.each_pair {|k,v|
    puts "#{k} : #{v.bid_rate} : #{v.ask_rate} : #{v.sell_swap} : #{v.buy_swap}"
  }
  
  # トレール注文
  # trail_rangeを指定するととレール注文になる。
  # 執行条件は逆指値限定なので、指定不要。
  begin
    order_id = session.order( SBIClient::FX::EURJPY, SBIClient::FX::BUY, 1, {
      :rate=>rates[SBIClient::FX::EURJPY].ask_rate + 0.5,
      :trail_range=>0.5,
      :expiration_type=>SBIClient::FX::EXPIRATION_TYPE_TODAY
    }) 
    print_order( session )
  ensure
    session.cancel_order(order_id.order_no) if order_id
  end
    
  begin
    order_id = session.order( SBIClient::FX::EURJPY, SBIClient::FX::SELL, 1, {
      :rate=>rates[SBIClient::FX::EURJPY].ask_rate - 0.5,
      :trail_range=>1.5, 
      :expiration_type=>SBIClient::FX::EXPIRATION_TYPE_SPECIFIED,
      :expiration_date=>Date.today+2
    })
    print_order( session )
  ensure
    session.cancel_order(order_id.order_no) if order_id
  end
}