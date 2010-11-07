# -*- coding: utf-8 -*- 

$: << "../lib"

require 'sbiclient'
require 'common'

describe "OCO" do
  it_should_behave_like "login"  do

    it "OCO-買x買-指値" do
      # 買いx買い。2つめの取引は逆指値になる
      @order_id = @s.order( SBIClient::FX::EURJPY, SBIClient::FX::BUY, 1, {
        :rate=>@rates[SBIClient::FX::EURJPY].ask_rate - 0.5, 
        :second_order_sell_or_buy=>SBIClient::FX::BUY,
        :second_order_rate=>@rates[SBIClient::FX::EURJPY].ask_rate + 0.5,
        :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_LIMIT_ORDER,
        :expiration_type=>SBIClient::FX::EXPIRATION_TYPE_TODAY
      })
      orders = @s.list_orders
      @order = orders[@order_id.order_no]
      @order_id.should_not be_nil
      @order_id.order_no.should_not be_nil
      @order.should_not be_nil
      @order.order_no.should == @order_id.order_no
      @order.trade_type.should == SBIClient::FX::TRADE_TYPE_NEW
      @order.execution_expression.should == SBIClient::FX::EXECUTION_EXPRESSION_LIMIT_ORDER
      @order.sell_or_buy.should == SBIClient::FX::BUY
      @order.pair.should == SBIClient::FX::EURJPY
      @order.count.should == 1
      normalize_rate(@order.rate).should == normalize_rate(@rates[SBIClient::FX::EURJPY].ask_rate - 0.5)
      @order.trail_range.should be_nil
      @order.order_type= SBIClient::FX::ORDER_TYPE_OCO
      
      @order = orders[(@order_id.order_no.to_i+1).to_s]
      @order.should_not be_nil
      @order.order_no.should == (@order_id.order_no.to_i+1).to_s
      @order.trade_type.should == SBIClient::FX::TRADE_TYPE_NEW
      @order.execution_expression.should == SBIClient::FX::EXECUTION_EXPRESSION_REVERSE_LIMIT_ORDER
      @order.sell_or_buy.should == SBIClient::FX::BUY
      @order.pair.should == SBIClient::FX::EURJPY
      @order.count.should == 1
      normalize_rate(@order.rate).should == normalize_rate(@rates[SBIClient::FX::EURJPY].ask_rate + 0.5)
      @order.trail_range.should be_nil
      @order.order_type= SBIClient::FX::ORDER_TYPE_OCO
    end
    
    it "OCO-売x売-指値" do
      # 売りx売り。2つめの取引は逆指値になる
      @order_id = @s.order( SBIClient::FX::GBPJPY, SBIClient::FX::SELL, 1, {
        :rate=>@rates[SBIClient::FX::GBPJPY].ask_rate + 0.5, 
        :second_order_sell_or_buy=>SBIClient::FX::SELL,
        :second_order_rate=>@rates[SBIClient::FX::GBPJPY].ask_rate - 0.5,
        :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_LIMIT_ORDER,
        :expiration_type=>SBIClient::FX::EXPIRATION_TYPE_WEEK_END
      })
      orders = @s.list_orders
      @order = orders[@order_id.order_no]
      @order_id.should_not be_nil
      @order_id.order_no.should_not be_nil
      @order.should_not be_nil
      @order.order_no.should == @order_id.order_no
      @order.trade_type.should == SBIClient::FX::TRADE_TYPE_NEW
      @order.execution_expression.should == SBIClient::FX::EXECUTION_EXPRESSION_LIMIT_ORDER
      @order.sell_or_buy.should == SBIClient::FX::SELL
      @order.pair.should == SBIClient::FX::GBPJPY
      @order.count.should == 1
      normalize_rate(@order.rate).should == normalize_rate(@rates[SBIClient::FX::GBPJPY].ask_rate + 0.5)
      @order.trail_range.should be_nil
      @order.order_type= SBIClient::FX::ORDER_TYPE_OCO
      
      @order = orders[(@order_id.order_no.to_i+1).to_s]
      @order.should_not be_nil
      @order.order_no.should == (@order_id.order_no.to_i+1).to_s
      @order.trade_type.should == SBIClient::FX::TRADE_TYPE_NEW
      @order.execution_expression.should == SBIClient::FX::EXECUTION_EXPRESSION_REVERSE_LIMIT_ORDER
      @order.sell_or_buy.should == SBIClient::FX::SELL
      @order.pair.should == SBIClient::FX::GBPJPY
      @order.count.should == 1
      normalize_rate(@order.rate).should == normalize_rate(@rates[SBIClient::FX::GBPJPY].ask_rate - 0.5)
      @order.trail_range.should be_nil
      @order.order_type= SBIClient::FX::ORDER_TYPE_OCO
    end
    
    it "OCO-買x売-指値" do
      # 買いx売り。両方とも指値になる
      @order_id = @s.order( SBIClient::FX::USDJPY, SBIClient::FX::BUY, 1, {
        :rate=>@rates[SBIClient::FX::USDJPY].ask_rate - 1, 
        :second_order_sell_or_buy=>SBIClient::FX::SELL,
        :second_order_rate=>@rates[SBIClient::FX::USDJPY].ask_rate + 1,
        :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_LIMIT_ORDER,
        :expiration_type=>SBIClient::FX::EXPIRATION_TYPE_TODAY
      })
      orders = @s.list_orders
      @order = orders[@order_id.order_no]
      @order_id.should_not be_nil
      @order_id.order_no.should_not be_nil
      @order.should_not be_nil
      @order.order_no.should == @order_id.order_no
      @order.trade_type.should == SBIClient::FX::TRADE_TYPE_NEW
      @order.execution_expression.should == SBIClient::FX::EXECUTION_EXPRESSION_LIMIT_ORDER
      @order.sell_or_buy.should == SBIClient::FX::BUY
      @order.pair.should == SBIClient::FX::USDJPY
      @order.count.should == 1
      normalize_rate(@order.rate).should == normalize_rate(@rates[SBIClient::FX::USDJPY].ask_rate - 1)
      @order.trail_range.should be_nil
      @order.order_type= SBIClient::FX::ORDER_TYPE_OCO
      
      @order = orders[(@order_id.order_no.to_i+1).to_s]
      @order.should_not be_nil
      @order.order_no.should == (@order_id.order_no.to_i+1).to_s
      @order.trade_type.should == SBIClient::FX::TRADE_TYPE_NEW
      @order.execution_expression.should == SBIClient::FX::EXECUTION_EXPRESSION_LIMIT_ORDER
      @order.sell_or_buy.should == SBIClient::FX::SELL
      @order.pair.should == SBIClient::FX::USDJPY
      @order.count.should == 1
      normalize_rate(@order.rate).should == normalize_rate(@rates[SBIClient::FX::USDJPY].ask_rate + 1)
      @order.trail_range.should be_nil
      @order.order_type= SBIClient::FX::ORDER_TYPE_OCO
    end
    
    it "OCO-売x買-指値" do
      
      # 買いx売り。両方とも指値になる
      @order_id = @s.order( SBIClient::FX::MZDJPY, SBIClient::FX::SELL, 2, {
        :rate=>@rates[SBIClient::FX::MZDJPY].ask_rate + 1, 
        :second_order_sell_or_buy=>SBIClient::FX::BUY,
        :second_order_rate=>@rates[SBIClient::FX::MZDJPY].ask_rate - 1,
        :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_LIMIT_ORDER,
        :expiration_type=>SBIClient::FX::EXPIRATION_TYPE_SPECIFIED,  # 有効期限: 指定
        :expiration_date=>Date.today+1
      })
      orders = @s.list_orders
      @order = orders[@order_id.order_no]
      @order_id.should_not be_nil
      @order_id.order_no.should_not be_nil
      @order.should_not be_nil
      @order.order_no.should == @order_id.order_no
      @order.trade_type.should == SBIClient::FX::TRADE_TYPE_NEW
      @order.execution_expression.should == SBIClient::FX::EXECUTION_EXPRESSION_LIMIT_ORDER
      @order.sell_or_buy.should == SBIClient::FX::SELL
      @order.pair.should == SBIClient::FX::MZDJPY
      @order.count.should == 2
      normalize_rate(@order.rate).should == normalize_rate(@rates[SBIClient::FX::MZDJPY].ask_rate + 1.0)
      @order.trail_range.should be_nil
      @order.order_type= SBIClient::FX::ORDER_TYPE_OCO
      
      @order = orders[(@order_id.order_no.to_i+1).to_s]
      @order.should_not be_nil
      @order.order_no.should == (@order_id.order_no.to_i+1).to_s
      @order.trade_type.should == SBIClient::FX::TRADE_TYPE_NEW
      @order.execution_expression.should == SBIClient::FX::EXECUTION_EXPRESSION_LIMIT_ORDER
      @order.sell_or_buy.should == SBIClient::FX::BUY
      @order.pair.should == SBIClient::FX::MZDJPY
      @order.count.should == 2
      normalize_rate(@order.rate).should == normalize_rate(@rates[SBIClient::FX::MZDJPY].ask_rate - 1.0)
      @order.trail_range.should be_nil
      @order.order_type= SBIClient::FX::ORDER_TYPE_OCO
    end
    
    it "OCO-買x買-逆指値" do
      # 買いx買い。2つめの取引は指値になる
      @order_id = @s.order( SBIClient::FX::EURJPY, SBIClient::FX::BUY, 1, {
        :rate=>@rates[SBIClient::FX::EURJPY].ask_rate + 0.5, 
        :second_order_sell_or_buy=>SBIClient::FX::BUY,
        :second_order_rate=>@rates[SBIClient::FX::EURJPY].ask_rate - 0.5,
        :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_REVERSE_LIMIT_ORDER,
        :expiration_type=>SBIClient::FX::EXPIRATION_TYPE_TODAY
      })
      orders = @s.list_orders
      @order = orders[@order_id.order_no]
      @order_id.should_not be_nil
      @order_id.order_no.should_not be_nil
      @order.should_not be_nil
      @order.order_no.should == @order_id.order_no
      @order.trade_type.should == SBIClient::FX::TRADE_TYPE_NEW
      @order.execution_expression.should == SBIClient::FX::EXECUTION_EXPRESSION_REVERSE_LIMIT_ORDER
      @order.sell_or_buy.should == SBIClient::FX::BUY
      @order.pair.should == SBIClient::FX::EURJPY
      @order.count.should == 1
      normalize_rate(@order.rate).should == normalize_rate(@rates[SBIClient::FX::EURJPY].ask_rate + 0.5)
      @order.trail_range.should be_nil
      @order.order_type= SBIClient::FX::ORDER_TYPE_OCO
      
      @order = orders[(@order_id.order_no.to_i+1).to_s]
      @order.should_not be_nil
      @order.order_no.should == (@order_id.order_no.to_i+1).to_s
      @order.trade_type.should == SBIClient::FX::TRADE_TYPE_NEW
      @order.execution_expression.should == SBIClient::FX::EXECUTION_EXPRESSION_LIMIT_ORDER
      @order.sell_or_buy.should == SBIClient::FX::BUY
      @order.pair.should == SBIClient::FX::EURJPY
      @order.count.should == 1
      normalize_rate(@order.rate).should == normalize_rate(@rates[SBIClient::FX::EURJPY].ask_rate - 0.5)
      @order.trail_range.should be_nil
      @order.order_type= SBIClient::FX::ORDER_TYPE_OCO
    end
    
    it "OCO-売x売-逆指値" do
      # 売りx売り。2つめの取引は指値になる
      @order_id = @s.order( SBIClient::FX::GBPJPY, SBIClient::FX::SELL, 1, {
        :rate=>@rates[SBIClient::FX::GBPJPY].ask_rate - 0.5, 
        :second_order_sell_or_buy=>SBIClient::FX::SELL,
        :second_order_rate=>@rates[SBIClient::FX::GBPJPY].ask_rate + 0.5,
        :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_REVERSE_LIMIT_ORDER,
        :expiration_type=>SBIClient::FX::EXPIRATION_TYPE_WEEK_END
      })
      orders = @s.list_orders
      @order = orders[@order_id.order_no]
      @order_id.should_not be_nil
      @order_id.order_no.should_not be_nil
      @order.should_not be_nil
      @order.order_no.should == @order_id.order_no
      @order.trade_type.should == SBIClient::FX::TRADE_TYPE_NEW
      @order.execution_expression.should == SBIClient::FX::EXECUTION_EXPRESSION_REVERSE_LIMIT_ORDER
      @order.sell_or_buy.should == SBIClient::FX::SELL
      @order.pair.should == SBIClient::FX::GBPJPY
      @order.count.should == 1
      normalize_rate(@order.rate).should == normalize_rate(@rates[SBIClient::FX::GBPJPY].ask_rate - 0.5)
      @order.trail_range.should be_nil
      @order.order_type= SBIClient::FX::ORDER_TYPE_OCO
      
      @order = orders[(@order_id.order_no.to_i+1).to_s]
      @order.should_not be_nil
      @order.order_no.should == (@order_id.order_no.to_i+1).to_s
      @order.trade_type.should == SBIClient::FX::TRADE_TYPE_NEW
      @order.execution_expression.should == SBIClient::FX::EXECUTION_EXPRESSION_LIMIT_ORDER
      @order.sell_or_buy.should == SBIClient::FX::SELL
      @order.pair.should == SBIClient::FX::GBPJPY
      @order.count.should == 1
      normalize_rate(@order.rate).should == normalize_rate(@rates[SBIClient::FX::GBPJPY].ask_rate + 0.5)
      @order.trail_range.should be_nil
      @order.order_type= SBIClient::FX::ORDER_TYPE_OCO
    end
    
    it "OCO-買x売-逆指値" do
      # 買いx売り。両方とも逆指値になる
      @order_id = @s.order( SBIClient::FX::USDJPY, SBIClient::FX::BUY, 1, {
        :rate=>@rates[SBIClient::FX::USDJPY].ask_rate + 1, 
        :second_order_sell_or_buy=>SBIClient::FX::SELL,
        :second_order_rate=>@rates[SBIClient::FX::USDJPY].ask_rate - 1,
        :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_REVERSE_LIMIT_ORDER,
        :expiration_type=>SBIClient::FX::EXPIRATION_TYPE_TODAY
      })
      orders = @s.list_orders
      @order = orders[@order_id.order_no]
      @order_id.should_not be_nil
      @order_id.order_no.should_not be_nil
      @order.should_not be_nil
      @order.order_no.should == @order_id.order_no
      @order.trade_type.should == SBIClient::FX::TRADE_TYPE_NEW
      @order.execution_expression.should == SBIClient::FX::EXECUTION_EXPRESSION_REVERSE_LIMIT_ORDER
      @order.sell_or_buy.should == SBIClient::FX::BUY
      @order.pair.should == SBIClient::FX::USDJPY
      @order.count.should == 1
      normalize_rate(@order.rate).should == normalize_rate(@rates[SBIClient::FX::USDJPY].ask_rate + 1)
      @order.trail_range.should be_nil
      @order.order_type= SBIClient::FX::ORDER_TYPE_OCO
      
      @order = orders[(@order_id.order_no.to_i+1).to_s]
      @order.should_not be_nil
      @order.order_no.should == (@order_id.order_no.to_i+1).to_s
      @order.trade_type.should == SBIClient::FX::TRADE_TYPE_NEW
      @order.execution_expression.should == SBIClient::FX::EXECUTION_EXPRESSION_REVERSE_LIMIT_ORDER
      @order.sell_or_buy.should == SBIClient::FX::SELL
      @order.pair.should == SBIClient::FX::USDJPY
      @order.count.should == 1
      normalize_rate(@order.rate).should == normalize_rate(@rates[SBIClient::FX::USDJPY].ask_rate - 1)
      @order.trail_range.should be_nil
      @order.order_type= SBIClient::FX::ORDER_TYPE_OCO
    end
    
    it "OCO-売りx買い" do
      # 買いx売り。両方とも指値になる
      @order_id = @s.order( SBIClient::FX::MZDJPY, SBIClient::FX::SELL, 2, {
        :rate=>@rates[SBIClient::FX::MZDJPY].ask_rate - 1, 
        :second_order_sell_or_buy=>SBIClient::FX::BUY,
        :second_order_rate=>@rates[SBIClient::FX::MZDJPY].ask_rate + 1,
        :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_REVERSE_LIMIT_ORDER,
        :expiration_type=>SBIClient::FX::EXPIRATION_TYPE_SPECIFIED, 
        :expiration_date=>Date.today+5
      })
      orders = @s.list_orders
      @order = orders[@order_id.order_no]
      @order_id.should_not be_nil
      @order_id.order_no.should_not be_nil
      @order.should_not be_nil
      @order.order_no.should == @order_id.order_no
      @order.trade_type.should == SBIClient::FX::TRADE_TYPE_NEW
      @order.execution_expression.should == SBIClient::FX::EXECUTION_EXPRESSION_REVERSE_LIMIT_ORDER
      @order.sell_or_buy.should == SBIClient::FX::SELL
      @order.pair.should == SBIClient::FX::MZDJPY
      @order.count.should == 2
      normalize_rate(@order.rate).should == normalize_rate(@rates[SBIClient::FX::MZDJPY].ask_rate - 1.0) 
      @order.trail_range.should be_nil
      @order.order_type= SBIClient::FX::ORDER_TYPE_OCO
      
      @order = orders[(@order_id.order_no.to_i+1).to_s]
      @order.should_not be_nil
      @order.order_no.should == (@order_id.order_no.to_i+1).to_s
      @order.trade_type.should == SBIClient::FX::TRADE_TYPE_NEW
      @order.execution_expression.should == SBIClient::FX::EXECUTION_EXPRESSION_REVERSE_LIMIT_ORDER
      @order.sell_or_buy.should == SBIClient::FX::BUY
      @order.pair.should == SBIClient::FX::MZDJPY
      @order.count.should == 2
      normalize_rate(@order.rate).should == normalize_rate(@rates[SBIClient::FX::MZDJPY].ask_rate + 1.0)
      @order.trail_range.should be_nil
      @order.order_type= SBIClient::FX::ORDER_TYPE_OCO
    end
    
  end
end
