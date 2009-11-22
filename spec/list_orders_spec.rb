$: << "../lib"

require 'sbiclient'
require 'common'

describe "list_orders" do
  it_should_behave_like "login"   
  before { @order_ids = [] }
  after { 
    @order_ids.each {|id| @s.cancel_order(id.order_no) } 
  }
  
  it "複数のページがあってもすべてのデータが取得できる" do
    3.times{|i|
      @order_ids << @s.order( SBIClient::FX::MURJPY, SBIClient::FX::BUY, 1, {
        :rate=>@rates[SBIClient::FX::MURJPY].ask_rate - 0.5,
        :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_LIMIT_ORDER,
        :expiration_type=>SBIClient::FX::EXPIRATION_TYPE_TODAY
      })
    }
    3.times{|i|
      @order_ids << @s.order( SBIClient::FX::MURJPY, SBIClient::FX::BUY, 1, {
        :rate=>@rates[SBIClient::FX::MURJPY].ask_rate - 0.5,
        :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_LIMIT_ORDER,
        :expiration_type=>SBIClient::FX::EXPIRATION_TYPE_TODAY,
        :settle => {
          :rate=>@rates[SBIClient::FX::MURJPY].ask_rate + 0.5,
          :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_LIMIT_ORDER
        }
      })
    }
    2.times{|i|
      @order_ids << @s.order( SBIClient::FX::MURJPY, SBIClient::FX::BUY, 1, {
        :rate=>@rates[SBIClient::FX::MURJPY].ask_rate - 0.5, 
        :second_order_sell_or_buy=>SBIClient::FX::BUY,
        :second_order_rate=>@rates[SBIClient::FX::MURJPY].ask_rate + 0.5,
        :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_LIMIT_ORDER,
        :expiration_type=>SBIClient::FX::EXPIRATION_TYPE_TODAY
      })
    }
    3.times{|i|
      @order_ids << @s.order( SBIClient::FX::MURJPY, SBIClient::FX::BUY, 1, {
       :rate=>@rates[SBIClient::FX::MURJPY].ask_rate + 0.5,
       :trail_range=>0.5,
       :expiration_type=>SBIClient::FX::EXPIRATION_TYPE_TODAY
      })
    }
    result = @s.list_orders
    result.size.should == 13 #OCOは2つになるので、3*3+2*2=13になる
  end
end
