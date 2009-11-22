$: << "../lib"

require 'sbiclient'
require 'common'

describe "cancel_order" do
  it_should_behave_like "login"   
  before { @order_ids = [] }
  after { 
    @order_ids.each {|id| @s.cancel_order(id.order_no) } 
  }
  
  it "複数のページがあってもキャンセルできる" do
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
    # 末尾から消していき、すべて削除できればOK。
    @order_ids.reverse.each {|id| 
      @s.cancel_order(id.order_no)
      @order_ids.pop
    }
    @s.list_orders.size.should == 0
  end
  
  it "削除対象が存在しない" do
    proc {
      @s.cancel_order("not found")
    }.should raise_error( RuntimeError, "illegal order_no. order_no=not found" )
  end
  
end
