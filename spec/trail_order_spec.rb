$: << "../lib"

require 'sbiclient'
require 'common'

describe "trail" do
  it_should_behave_like "login"   

  it "買い" do
    @order_id = @s.order( SBIClient::FX::EURUSD, SBIClient::FX::BUY, 1, {
     :rate=>@rates[SBIClient::FX::EURUSD].ask_rate + 0.05,
     :trail_range=>0.5,
     :expiration_type=>SBIClient::FX::EXPIRATION_TYPE_TODAY
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
    @order.trail_range.to_s.should == (0.5).to_s
    @order.order_type= SBIClient::FX::ORDER_TYPE_TRAIL
  end
    
  it "売り" do
    @order_id = @s.order( SBIClient::FX::MURJPY, SBIClient::FX::SELL, 2, {
      :rate=>@rates[SBIClient::FX::MURJPY].ask_rate - 0.5,
      :trail_range=>1,
      :expiration_type=>SBIClient::FX::EXPIRATION_TYPE_SPECIFIED,  # 有効期限: 指定
      :expiration_date=>Date.today+2 # 2日後
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
    @order.trail_range.to_s.should == (1.0).to_s
    @order.order_type= SBIClient::FX::ORDER_TYPE_TRAIL
  end
end
