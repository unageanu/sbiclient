# -*- coding: utf-8 -*- 

$: << "."
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
  
  ## 指値注文  
  begin
    order_id = session.order( SBIClient::FX::EURJPY, SBIClient::FX::BUY, 1, {
      :rate=>rates[SBIClient::FX::EURJPY].ask_rate - 0.5, # 指値レート
      :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_LIMIT_ORDER, # 執行条件: 指値 
      :expiration_type=>SBIClient::FX::EXPIRATION_TYPE_TODAY  # 有効期限: 当日限り 
    })
    print_order( session )
  ensure
    session.cancel_order(order_id.order_no) if order_id
  end
    
  begin
    order_id = session.order( SBIClient::FX::EURJPY, SBIClient::FX::SELL, 1, {
      :rate=>rates[SBIClient::FX::EURJPY].ask_rate + 0.5, # 指値レート
      :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_LIMIT_ORDER, # 執行条件: 指値 
      :expiration_type=>SBIClient::FX::EXPIRATION_TYPE_WEEK_END  # 有効期限: 週末まで
    })
    print_order( session )
  ensure
    session.cancel_order(order_id.order_no) if order_id
  end
    
  
  # 逆指値注文
  begin
    order_id = session.order( SBIClient::FX::EURJPY, SBIClient::FX::BUY, 1, {
      :rate=>rates[SBIClient::FX::EURJPY].ask_rate + 0.5, # 逆指値レート
      :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_REVERSE_LIMIT_ORDER, # 執行条件: 逆指値 
      :expiration_type=>SBIClient::FX::EXPIRATION_TYPE_TODAY  # 有効期限: 無限
    }) 
    print_order( session )
  ensure
    session.cancel_order(order_id.order_no) if order_id
  end
    
  begin
    order_id = session.order( SBIClient::FX::EURJPY, SBIClient::FX::SELL, 1, {
      :rate=>rates[SBIClient::FX::EURJPY].ask_rate - 0.5, # 逆指値レート
      :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_REVERSE_LIMIT_ORDER, # 執行条件: 逆指値 
      :expiration_type=>SBIClient::FX::EXPIRATION_TYPE_SPECIFIED,  # 有効期限: 指定
      :expiration_date=>Date.today+2 # 2日後
    })
    print_order( session )
  ensure
    session.cancel_order(order_id.order_no) if order_id
  end
}