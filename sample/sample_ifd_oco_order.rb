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
  
  ## IFD-OCO注文 
  # 指値
  begin
    order_id = session.order( SBIClient::FX::EURJPY, SBIClient::FX::BUY, 1, {
      :rate=>rates[SBIClient::FX::EURJPY].ask_rate - 0.5, 
      :settle=> {
        :rate=>rates[SBIClient::FX::EURJPY].ask_rate + 0.5, 
        :stop_order_rate=>rates[SBIClient::FX::EURJPY].ask_rate - 1 
      },
      :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_LIMIT_ORDER,
      :expiration_type=>SBIClient::FX::EXPIRATION_TYPE_TODAY
    })
    print_order( session )
  ensure
    session.cancel_order(order_id.order_no) if order_id
  end
  
  begin
    order_id = session.order( SBIClient::FX::EURJPY, SBIClient::FX::SELL, 1, {
      :rate=>rates[SBIClient::FX::EURJPY].ask_rate + 0.5,
      :settle=> {
        :rate=>rates[SBIClient::FX::EURJPY].ask_rate - 0.5, 
        :stop_order_rate=>rates[SBIClient::FX::EURJPY].ask_rate + 1 
      },
      :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_LIMIT_ORDER, 
      :expiration_type=>SBIClient::FX::EXPIRATION_TYPE_WEEK_END
    })
    print_order( session )
  ensure
    session.cancel_order(order_id.order_no) if order_id
  end
    
    
  # 逆指値  
  begin
    order_id = session.order( SBIClient::FX::EURJPY, SBIClient::FX::BUY, 1, {
      :rate=>rates[SBIClient::FX::EURJPY].ask_rate + 0.5, 
      :settle=> {
        :rate=>rates[SBIClient::FX::EURJPY].ask_rate + 1, 
        :stop_order_rate=>rates[SBIClient::FX::EURJPY].ask_rate 
      },
      :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_REVERSE_LIMIT_ORDER,
      :expiration_type=>SBIClient::FX::EXPIRATION_TYPE_TODAY
    })
    print_order( session )
  ensure
    session.cancel_order(order_id.order_no) if order_id
  end
  
  begin
    order_id = session.order( SBIClient::FX::EURJPY, SBIClient::FX::SELL, 1, {
      :rate=>rates[SBIClient::FX::EURJPY].ask_rate - 0.5,
      :settle=> {
        :rate=>rates[SBIClient::FX::EURJPY].ask_rate - 1, 
        :stop_order_rate=>rates[SBIClient::FX::EURJPY].ask_rate 
      },
      :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_REVERSE_LIMIT_ORDER, 
      :expiration_type=>SBIClient::FX::EXPIRATION_TYPE_WEEK_END
    })
    print_order( session )
  ensure
    session.cancel_order(order_id.order_no) if order_id
  end
}