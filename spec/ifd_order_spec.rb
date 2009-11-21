$: << "../lib"

require 'sbiclient'
require 'common'

describe "IFD" do
  it_should_behave_like "login"   
  
  it "指値-指値" do
    @order_id = @s.order( SBIClient::FX::EURJPY, SBIClient::FX::BUY, 1, {
      :rate=>@rates[SBIClient::FX::EURJPY].ask_rate - 0.5,
      :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_LIMIT_ORDER,
      :expiration_type=>SBIClient::FX::EXPIRATION_TYPE_TODAY,
      :settle => {
        :rate=>@rates[SBIClient::FX::EURJPY].ask_rate + 0.5,
        :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_LIMIT_ORDER
      }
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
    @order.rate.should == @rates[SBIClient::FX::EURJPY].ask_rate - 0.5
    @order.trail_range.should be_nil
    @order.order_type= SBIClient::FX::ORDER_TYPE_IFD
  end

  it "指値-逆指値" do
    @order_id = @s.order( SBIClient::FX::USDJPY, SBIClient::FX::SELL, 1, {
      :rate=>@rates[SBIClient::FX::USDJPY].ask_rate + 0.5,
      :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_LIMIT_ORDER,
      :expiration_type=>SBIClient::FX::EXPIRATION_TYPE_WEEK_END,
      :settle => {
        :rate=>@rates[SBIClient::FX::USDJPY].ask_rate + 1,
        :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_REVERSE_LIMIT_ORDER
      }
    })
    @order = @s.list_orders[@order_id.order_no]
    @order_id.should_not be_nil
    @order_id.order_no.should_not be_nil
    @order.should_not be_nil
    @order.order_no.should == @order_id.order_no
    @order.trade_type.should == SBIClient::FX::TRADE_TYPE_NEW
    @order.execution_expression.should == SBIClient::FX::EXECUTION_EXPRESSION_LIMIT_ORDER
    @order.sell_or_buy.should == SBIClient::FX::SELL
    @order.pair.should == SBIClient::FX::USDJPY
    @order.count.should == 1
    @order.rate.should == @rates[SBIClient::FX::USDJPY].ask_rate + 0.5
    @order.trail_range.should be_nil
    @order.order_type= SBIClient::FX::ORDER_TYPE_IFD
  end

  it "逆指値-逆指値" do
    @order_id = @s.order( SBIClient::FX::EURUSD, SBIClient::FX::BUY, 1, {
     :rate=>@rates[SBIClient::FX::EURUSD].ask_rate + 0.05,
     :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_REVERSE_LIMIT_ORDER,
     :expiration_type=>SBIClient::FX::EXPIRATION_TYPE_TODAY,
     :settle => {
        :rate=>@rates[SBIClient::FX::EURUSD].ask_rate,
        :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_REVERSE_LIMIT_ORDER
      }
    })
    @order_id.should_not be_nil
    @order_id.order_no.should_not be_nil
    @order = @s.list_orders[@order_id.order_no]
    @order.should_not be_nil
    @order.order_no.should == @order_id.order_no
    @order.trade_type.should == SBIClient::FX::TRADE_TYPE_NEW
    @order.execution_expression.should == SBIClient::FX::EXECUTION_EXPRESSION_REVERSE_LIMIT_ORDER
    @order.sell_or_buy.should == SBIClient::FX::BUY
    @order.pair.should == SBIClient::FX::EURUSD
    @order.count.should == 1
    @order.rate.to_s.should == (@rates[SBIClient::FX::EURUSD].ask_rate + 0.05).to_s
    @order.trail_range.should be_nil
    @order.order_type= SBIClient::FX::ORDER_TYPE_IFD
  end
    
  it "逆指値-指値" do
    @order_id = @s.order( SBIClient::FX::MURJPY, SBIClient::FX::SELL, 2, {
      :rate=>@rates[SBIClient::FX::MURJPY].ask_rate - 0.5,
      :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_REVERSE_LIMIT_ORDER,
      :expiration_type=>SBIClient::FX::EXPIRATION_TYPE_SPECIFIED, 
      :expiration_date=>Date.today+2,
      :settle => {
        :rate=>@rates[SBIClient::FX::MURJPY].ask_rate - 1,
        :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_LIMIT_ORDER
      }
    })
    @order = @s.list_orders[@order_id.order_no]
    @order_id.should_not be_nil
    @order_id.order_no.should_not be_nil
    @order.should_not be_nil
    @order.order_no.should == @order_id.order_no
    @order.trade_type.should == SBIClient::FX::TRADE_TYPE_NEW
    @order.execution_expression.should == SBIClient::FX::EXECUTION_EXPRESSION_REVERSE_LIMIT_ORDER
    @order.sell_or_buy.should == SBIClient::FX::SELL
    @order.pair.should == SBIClient::FX::MURJPY
    @order.count.should == 2
    @order.rate.should == @rates[SBIClient::FX::MURJPY].ask_rate - 0.5
    @order.trail_range.should be_nil
    @order.order_type= SBIClient::FX::ORDER_TYPE_IFD
  end
end