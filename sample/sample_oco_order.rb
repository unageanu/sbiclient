
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
  
  ## OCO注文 
  # BUY-BUY,SELL-SELLの組み合わせ。
  # BUY指値-BUY逆指値  
  begin
    order_id = session.order( SBIClient::FX::EURJPY, SBIClient::FX::BUY, 1, {
      :rate=>rates[SBIClient::FX::EURJPY].ask_rate - 0.5, 
      :second_order_sell_or_buy=>SBIClient::FX::BUY,
      :second_order_rate=>rates[SBIClient::FX::EURJPY].ask_rate + 0.5,
      :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_LIMIT_ORDER,
      :expiration_type=>SBIClient::FX::EXPIRATION_TYPE_TODAY
    })
    print_order( session )
  ensure
    session.cancel_order(order_id.order_no) if order_id
  end
  
  # SELL指値-SELL逆指値 
  begin
    order_id = session.order( SBIClient::FX::EURJPY, SBIClient::FX::SELL, 1, {
      :rate=>rates[SBIClient::FX::EURJPY].ask_rate + 0.5,
      :second_order_sell_or_buy=>SBIClient::FX::SELL,
      :second_order_rate=>rates[SBIClient::FX::EURJPY].ask_rate - 0.5,
      :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_LIMIT_ORDER, 
      :expiration_type=>SBIClient::FX::EXPIRATION_TYPE_WEEK_END
    })
    print_order( session )
  ensure
    session.cancel_order(order_id.order_no) if order_id
  end
  
    # BUY逆指値-BUY指値  
  begin
    order_id = session.order( SBIClient::FX::EURJPY, SBIClient::FX::BUY, 1, {
      :rate=>rates[SBIClient::FX::EURJPY].ask_rate + 0.5, 
      :second_order_sell_or_buy=>SBIClient::FX::BUY,
      :second_order_rate=>rates[SBIClient::FX::EURJPY].ask_rate - 0.5,
      :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_REVERSE_LIMIT_ORDER,
      :expiration_type=>SBIClient::FX::EXPIRATION_TYPE_TODAY
    })
    print_order( session )
  ensure
    session.cancel_order(order_id.order_no) if order_id
  end
  
  # SELL逆指値-SELL指値 
  begin
    order_id = session.order( SBIClient::FX::EURJPY, SBIClient::FX::SELL, 1, {
      :rate=>rates[SBIClient::FX::EURJPY].ask_rate - 0.5,
      :second_order_sell_or_buy=>SBIClient::FX::SELL,
      :second_order_rate=>rates[SBIClient::FX::EURJPY].ask_rate + 0.5,
      :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_REVERSE_LIMIT_ORDER, 
      :expiration_type=>SBIClient::FX::EXPIRATION_TYPE_WEEK_END
    })
    print_order( session )
  ensure
    session.cancel_order(order_id.order_no) if order_id
  end
  

  # BUY-SELLの組み合わせ。
  # BUY指値-SELL指値  
  begin
    order_id = session.order( SBIClient::FX::EURJPY, SBIClient::FX::BUY, 1, {
      :rate=>rates[SBIClient::FX::EURJPY].ask_rate - 0.5, 
      :second_order_sell_or_buy=>SBIClient::FX::SELL,
      :second_order_rate=>rates[SBIClient::FX::EURJPY].ask_rate + 0.5,
      :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_LIMIT_ORDER,
      :expiration_type=>SBIClient::FX::EXPIRATION_TYPE_TODAY
    })
    print_order( session )
  ensure
    session.cancel_order(order_id.order_no) if order_id
  end
  
  # BUY指値-SELL指値 
  begin
    order_id = session.order( SBIClient::FX::EURJPY, SBIClient::FX::SELL, 1, {
      :rate=>rates[SBIClient::FX::EURJPY].ask_rate + 0.5,
      :second_order_sell_or_buy=>SBIClient::FX::BUY,
      :second_order_rate=>rates[SBIClient::FX::EURJPY].ask_rate - 0.5,
      :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_LIMIT_ORDER, 
      :expiration_type=>SBIClient::FX::EXPIRATION_TYPE_WEEK_END
    })
    print_order( session )
  ensure
    session.cancel_order(order_id.order_no) if order_id
  end
  
  # BUY逆指値-SELL指値  
  order_id = session.order( SBIClient::FX::EURJPY, SBIClient::FX::BUY, 1, {
    :rate=>rates[SBIClient::FX::EURJPY].ask_rate + 0.5, 
    :second_order_sell_or_buy=>SBIClient::FX::SELL,
    :second_order_rate=>rates[SBIClient::FX::EURJPY].ask_rate - 0.5,
    :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_REVERSE_LIMIT_ORDER,
    :expiration_type=>SBIClient::FX::EXPIRATION_TYPE_TODAY
  })
  print_order( session )
  session.cancel_order(order_id.order_no) if order_id
  
  # SELL逆指値-BUY指値 
  order_id = session.order( SBIClient::FX::EURJPY, SBIClient::FX::SELL, 1, {
    :rate=>rates[SBIClient::FX::EURJPY].ask_rate - 0.5,
    :second_order_sell_or_buy=>SBIClient::FX::BUY,
    :second_order_rate=>rates[SBIClient::FX::EURJPY].ask_rate + 0.5,
    :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_REVERSE_LIMIT_ORDER, 
    :expiration_type=>SBIClient::FX::EXPIRATION_TYPE_WEEK_END
  })
  print_order( session )
  session.cancel_order(order_id.order_no) if order_id
}