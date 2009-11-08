$: << "../lib"

require 'sbiclient'
require 'common'

describe "指値/逆指値注文" do
  it_should_behave_like "login"   
  
  it "指値-買い" do
    @order_id = @s.order( SBIClient::FX::EURJPY, SBIClient::FX::BUY, 1, {
      :rate=>@rates[SBIClient::FX::EURJPY].ask_rate - 0.5,
      :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_LIMIT_ORDER,
      :expiration_type=>SBIClient::FX::EXPIRATION_TYPE_TODAY
    })
    @order = @s.list_orders[@order_id.order_no]
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
  end

  it "指値-売り" do
    @order_id = @s.order( SBIClient::FX::USDJPY, SBIClient::FX::SELL, 1, {
      :rate=>@rates[SBIClient::FX::USDJPY].ask_rate + 0.5,
      :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_LIMIT_ORDER,
      :expiration_type=>SBIClient::FX::EXPIRATION_TYPE_WEEK_END
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
  end

  it "逆指値-買い" do
    @order_id = @s.order( SBIClient::FX::EURUSD, SBIClient::FX::BUY, 1, {
     :rate=>@rates[SBIClient::FX::EURUSD].ask_rate + 0.05,
     :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_REVERSE_LIMIT_ORDER,
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
    @order.rate.should.to_s == (@rates[SBIClient::FX::EURUSD].ask_rate + 0.05).to_s
  end
    
  it "逆指値-売り" do
    @order_id = @s.order( SBIClient::FX::MURJPY, SBIClient::FX::SELL, 2, {
      :rate=>@rates[SBIClient::FX::MURJPY].ask_rate - 0.5,
      :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_REVERSE_LIMIT_ORDER,
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
  end
end

describe "OCO注文" do
  it_should_behave_like "login"   

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
    @order.rate.should == @rates[SBIClient::FX::EURJPY].ask_rate - 0.5
    
    @order = orders[(@order_id.order_no.to_i+1).to_s]
    @order.should_not be_nil
    @order.order_no.should == (@order_id.order_no.to_i+1).to_s
    @order.trade_type.should == SBIClient::FX::TRADE_TYPE_NEW
    @order.execution_expression.should == SBIClient::FX::EXECUTION_EXPRESSION_REVERSE_LIMIT_ORDER
    @order.sell_or_buy.should == SBIClient::FX::BUY
    @order.pair.should == SBIClient::FX::EURJPY
    @order.count.should == 1
    @order.rate.should == @rates[SBIClient::FX::EURJPY].ask_rate + 0.5
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
    @order.rate.should == @rates[SBIClient::FX::GBPJPY].ask_rate + 0.5
    
    @order = orders[(@order_id.order_no.to_i+1).to_s]
    @order.should_not be_nil
    @order.order_no.should == (@order_id.order_no.to_i+1).to_s
    @order.trade_type.should == SBIClient::FX::TRADE_TYPE_NEW
    @order.execution_expression.should == SBIClient::FX::EXECUTION_EXPRESSION_REVERSE_LIMIT_ORDER
    @order.sell_or_buy.should == SBIClient::FX::SELL
    @order.pair.should == SBIClient::FX::GBPJPY
    @order.count.should == 1
    @order.rate.should == @rates[SBIClient::FX::GBPJPY].ask_rate - 0.5
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
    @order.rate.should == @rates[SBIClient::FX::USDJPY].ask_rate - 1
    
    @order = orders[(@order_id.order_no.to_i+1).to_s]
    @order.should_not be_nil
    @order.order_no.should == (@order_id.order_no.to_i+1).to_s
    @order.trade_type.should == SBIClient::FX::TRADE_TYPE_NEW
    @order.execution_expression.should == SBIClient::FX::EXECUTION_EXPRESSION_LIMIT_ORDER
    @order.sell_or_buy.should == SBIClient::FX::SELL
    @order.pair.should == SBIClient::FX::USDJPY
    @order.count.should == 1
    @order.rate.should == @rates[SBIClient::FX::USDJPY].ask_rate + 1
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
    @order.rate.should == @rates[SBIClient::FX::MZDJPY].ask_rate + 1
    
    @order = orders[(@order_id.order_no.to_i+1).to_s]
    @order.should_not be_nil
    @order.order_no.should == (@order_id.order_no.to_i+1).to_s
    @order.trade_type.should == SBIClient::FX::TRADE_TYPE_NEW
    @order.execution_expression.should == SBIClient::FX::EXECUTION_EXPRESSION_LIMIT_ORDER
    @order.sell_or_buy.should == SBIClient::FX::BUY
    @order.pair.should == SBIClient::FX::MZDJPY
    @order.count.should == 2
    @order.rate.should == @rates[SBIClient::FX::MZDJPY].ask_rate - 1
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
    @order.rate.should == @rates[SBIClient::FX::EURJPY].ask_rate + 0.5
    
    @order = orders[(@order_id.order_no.to_i+1).to_s]
    @order.should_not be_nil
    @order.order_no.should == (@order_id.order_no.to_i+1).to_s
    @order.trade_type.should == SBIClient::FX::TRADE_TYPE_NEW
    @order.execution_expression.should == SBIClient::FX::EXECUTION_EXPRESSION_LIMIT_ORDER
    @order.sell_or_buy.should == SBIClient::FX::BUY
    @order.pair.should == SBIClient::FX::EURJPY
    @order.count.should == 1
    @order.rate.should == @rates[SBIClient::FX::EURJPY].ask_rate - 0.5
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
    @order.rate.should == @rates[SBIClient::FX::GBPJPY].ask_rate - 0.5
    
    @order = orders[(@order_id.order_no.to_i+1).to_s]
    @order.should_not be_nil
    @order.order_no.should == (@order_id.order_no.to_i+1).to_s
    @order.trade_type.should == SBIClient::FX::TRADE_TYPE_NEW
    @order.execution_expression.should == SBIClient::FX::EXECUTION_EXPRESSION_LIMIT_ORDER
    @order.sell_or_buy.should == SBIClient::FX::SELL
    @order.pair.should == SBIClient::FX::GBPJPY
    @order.count.should == 1
    @order.rate.should == @rates[SBIClient::FX::GBPJPY].ask_rate + 0.5
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
    @order.rate.should == @rates[SBIClient::FX::USDJPY].ask_rate + 1
    
    @order = orders[(@order_id.order_no.to_i+1).to_s]
    @order.should_not be_nil
    @order.order_no.should == (@order_id.order_no.to_i+1).to_s
    @order.trade_type.should == SBIClient::FX::TRADE_TYPE_NEW
    @order.execution_expression.should == SBIClient::FX::EXECUTION_EXPRESSION_REVERSE_LIMIT_ORDER
    @order.sell_or_buy.should == SBIClient::FX::SELL
    @order.pair.should == SBIClient::FX::USDJPY
    @order.count.should == 1
    @order.rate.should == @rates[SBIClient::FX::USDJPY].ask_rate - 1
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
    @order.rate.should == @rates[SBIClient::FX::MZDJPY].ask_rate - 1
    
    @order = orders[(@order_id.order_no.to_i+1).to_s]
    @order.should_not be_nil
    @order.order_no.should == (@order_id.order_no.to_i+1).to_s
    @order.trade_type.should == SBIClient::FX::TRADE_TYPE_NEW
    @order.execution_expression.should == SBIClient::FX::EXECUTION_EXPRESSION_REVERSE_LIMIT_ORDER
    @order.sell_or_buy.should == SBIClient::FX::BUY
    @order.pair.should == SBIClient::FX::MZDJPY
    @order.count.should == 2
    @order.rate.should == @rates[SBIClient::FX::MZDJPY].ask_rate + 1
  end
  
end