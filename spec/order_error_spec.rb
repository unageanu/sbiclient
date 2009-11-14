$: << "../lib"

require 'sbiclient'
require 'common'

describe "注文の異常系テスト" do
  it_should_behave_like "login"
  
  it "指値/逆指値" do
    # 執行条件の指定がない
    proc {
      @s.order( SBIClient::FX::MURJPY, SBIClient::FX::SELL, 1, {
          :rate=>@rates[SBIClient::FX::MURJPY].ask_rate - 0.5,
          :expiration_type=>SBIClient::FX::EXPIRATION_TYPE_TODAY
        })
    }.should raise_error( RuntimeError, "options[:execution_expression] is required." )
    
    # 有効期限の指定がない
    proc {
      @s.order( SBIClient::FX::MURJPY, SBIClient::FX::SELL, 1, {
          :rate=>@rates[SBIClient::FX::MURJPY].ask_rate - 0.5,
          :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_REVERSE_LIMIT_ORDER,
        })
    }.should raise_error( RuntimeError, "options[:expiration_type] is required." )
    
    # 日付指定であるのに日時の指定がない
    proc {
      @s.order( SBIClient::FX::MURJPY, SBIClient::FX::SELL, 1, {
          :rate=>@rates[SBIClient::FX::MURJPY].ask_rate - 0.5,
          :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_REVERSE_LIMIT_ORDER,
          :expiration_type=>SBIClient::FX::EXPIRATION_TYPE_SPECIFIED
        })
    }.should raise_error( RuntimeError, "options[:expiration_date] is required." )

    # 日付指定の範囲が不正
    proc {
      @s.order( SBIClient::FX::MURJPY, SBIClient::FX::SELL, 1, {
          :rate=>@rates[SBIClient::FX::MURJPY].ask_rate - 0.5,
          :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_REVERSE_LIMIT_ORDER,
          :expiration_type=>SBIClient::FX::EXPIRATION_TYPE_SPECIFIED,
          :expiration_date=>Date.today
        })
    }.should raise_error( RuntimeError )

    # レートが不正
    proc {
      @s.order( SBIClient::FX::MURJPY, SBIClient::FX::SELL, 1, {
          :rate=>"-10000000",
          :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_LIMIT_ORDER,
          :expiration_type=>SBIClient::FX::EXPIRATION_TYPE_TODAY
        })
    }.should raise_error( RuntimeError )

    # 取引数量が不正
    proc {
      @s.order( SBIClient::FX::MURJPY, SBIClient::FX::SELL, -1, {
          :rate=>@rates[SBIClient::FX::MURJPY].ask_rate + 0.5,
          :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_LIMIT_ORDER,
          :expiration_type=>SBIClient::FX::EXPIRATION_TYPE_TODAY
        })
    }.should raise_error( RuntimeError )

    proc {
      @s.order( SBIClient::FX::MURJPY, SBIClient::FX::SELL, 0, {
          :rate=>@rates[SBIClient::FX::MURJPY].ask_rate + 0.5,
          :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_LIMIT_ORDER,
          :expiration_type=>SBIClient::FX::EXPIRATION_TYPE_TODAY
        })
    }.should raise_error( RuntimeError )

    proc {
      @s.order( SBIClient::FX::MURJPY, SBIClient::FX::SELL, 1000, {
          :rate=>@rates[SBIClient::FX::MURJPY].ask_rate + 0.5,
          :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_LIMIT_ORDER,
          :expiration_type=>SBIClient::FX::EXPIRATION_TYPE_TODAY
        })
    }.should raise_error( RuntimeError )

    # 不利な注文
    proc {
      @s.order( SBIClient::FX::MURJPY, SBIClient::FX::SELL, 1, {
          :rate=>@rates[SBIClient::FX::MURJPY].ask_rate - 0.5,
          :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_LIMIT_ORDER,
          :expiration_type=>SBIClient::FX::EXPIRATION_TYPE_TODAY
        })
    }.should raise_error( RuntimeError )
    
    proc {
      @s.order( SBIClient::FX::MURJPY, SBIClient::FX::SELL, 1, {
          :rate=>@rates[SBIClient::FX::MURJPY].ask_rate + 0.5,
          :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_REVERSE_LIMIT_ORDER,
          :expiration_type=>SBIClient::FX::EXPIRATION_TYPE_TODAY
        })
    }.should raise_error( RuntimeError )
  end

  it "OCO" do
    # 執行条件の指定がない
    proc {
      @s.order( SBIClient::FX::EURJPY, SBIClient::FX::SELL, 1, {
        :rate=>@rates[SBIClient::FX::EURJPY].ask_rate - 0.5, 
        :second_order_sell_or_buy=>SBIClient::FX::BUY,
        :second_order_rate=>@rates[SBIClient::FX::EURJPY].ask_rate + 0.5,
        :expiration_type=>SBIClient::FX::EXPIRATION_TYPE_TODAY
      })
    }.should raise_error( RuntimeError, "options[:execution_expression] is required." )
    
    # 有効期限の指定がない
    proc {
      @s.order( SBIClient::FX::EURJPY, SBIClient::FX::SELL, 1, {
        :rate=>@rates[SBIClient::FX::EURJPY].ask_rate + 0.5, 
        :second_order_sell_or_buy=>SBIClient::FX::BUY,
        :second_order_rate=>@rates[SBIClient::FX::EURJPY].ask_rate - 0.5,
        :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_LIMIT_ORDER,
      })
    }.should raise_error( RuntimeError, "options[:expiration_type] is required." )
    
    # 不利な注文
    proc {
      @s.order( SBIClient::FX::MURJPY, SBIClient::FX::SELL, 1, {
          :rate=>@rates[SBIClient::FX::MURJPY].ask_rate - 0.5,
          :second_order_sell_or_buy=>SBIClient::FX::BUY,
          :second_order_rate=>@rates[SBIClient::FX::EURJPY].ask_rate - 0.5,
          :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_LIMIT_ORDER,
          :expiration_type=>SBIClient::FX::EXPIRATION_TYPE_TODAY
        })
    }.should raise_error( RuntimeError )
    
    proc {
      @s.order( SBIClient::FX::MURJPY, SBIClient::FX::SELL, 1, {
          :rate=>@rates[SBIClient::FX::MURJPY].ask_rate + 0.5,
          :second_order_sell_or_buy=>SBIClient::FX::BUY,
          :second_order_rate=>@rates[SBIClient::FX::EURJPY].ask_rate + 0.5,
          :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_REVERSE_LIMIT_ORDER,
          :expiration_type=>SBIClient::FX::EXPIRATION_TYPE_TODAY
        })
    }.should raise_error( RuntimeError )
  end
  
  it "IFD" do
    # 執行条件の指定がない
    proc {
      @s.order( SBIClient::FX::EURJPY, SBIClient::FX::SELL, 1, {
        :rate=>@rates[SBIClient::FX::EURJPY].ask_rate - 0.5, 
        :expiration_type=>SBIClient::FX::EXPIRATION_TYPE_TODAY,
        :settle => {
          :rate=>@rates[SBIClient::FX::MURJPY].ask_rate - 1,
          :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_LIMIT_ORDER
        }
      })
    }.should raise_error( RuntimeError, "options[:execution_expression] is required." )
    
    # 有効期限の指定がない
    proc {
      @s.order( SBIClient::FX::EURJPY, SBIClient::FX::SELL, 1, {
        :rate=>@rates[SBIClient::FX::EURJPY].ask_rate + 0.5, 
        :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_LIMIT_ORDER,
        :settle => {
          :rate=>@rates[SBIClient::FX::MURJPY].ask_rate - 1,
          :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_LIMIT_ORDER
        }
      })
    }.should raise_error( RuntimeError, "options[:expiration_type] is required." )
    
    # 決済取引のレートの指定がない
    proc {
      @s.order( SBIClient::FX::EURJPY, SBIClient::FX::SELL, 1, {
        :rate=>@rates[SBIClient::FX::EURJPY].ask_rate + 0.5, 
        :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_LIMIT_ORDER,
        :expiration_type=>SBIClient::FX::EXPIRATION_TYPE_TODAY,
        :settle => {
          :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_LIMIT_ORDER
        }
      })
    }.should raise_error( RuntimeError, "options[:settle][:rate] is required." )
   
    # 決済取引の取引種別の指定がない
    proc {
      @s.order( SBIClient::FX::EURJPY, SBIClient::FX::SELL, 1, {
        :rate=>@rates[SBIClient::FX::EURJPY].ask_rate + 0.5, 
        :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_LIMIT_ORDER,
        :expiration_type=>SBIClient::FX::EXPIRATION_TYPE_TODAY,
        :settle => {
          :rate=>@rates[SBIClient::FX::MURJPY].ask_rate - 1
        }
      })
    }.should raise_error( RuntimeError, "options[:settle][:execution_expression] is required." )
   
    # 不利な注文
    proc {
      @s.order( SBIClient::FX::MURJPY, SBIClient::FX::SELL, 1, {
          :rate=>@rates[SBIClient::FX::MURJPY].ask_rate - 0.5,
          :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_LIMIT_ORDER,
          :expiration_type=>SBIClient::FX::EXPIRATION_TYPE_TODAY,
          :settle => {
            :rate=>@rates[SBIClient::FX::MURJPY].ask_rate + 1,
            :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_LIMIT_ORDER
          }
        }) 
    }.should raise_error( RuntimeError )
    
    proc {
      @s.order( SBIClient::FX::MURJPY, SBIClient::FX::SELL, 1, {
          :rate=>@rates[SBIClient::FX::MURJPY].ask_rate + 0.5,
          :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_REVERSE_LIMIT_ORDER,
          :expiration_type=>SBIClient::FX::EXPIRATION_TYPE_TODAY,
          :settle => {
            :rate=>@rates[SBIClient::FX::MURJPY].ask_rate + 1,
            :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_LIMIT_ORDER
          }
        })
    }.should raise_error( RuntimeError )
    
    # 決済注文レートが不正
    proc {
      @s.order( SBIClient::FX::MURJPY, SBIClient::FX::SELL, 1, {
          :rate=>@rates[SBIClient::FX::MURJPY].ask_rate + 0.5,
          :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_LIMIT_ORDER,
          :expiration_type=>SBIClient::FX::EXPIRATION_TYPE_TODAY,
          :settle => {
            :rate=>@rates[SBIClient::FX::MURJPY].ask_rate + 1,
            :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_LIMIT_ORDER
          }
        })
    }.should raise_error( RuntimeError )
    
    proc {
      @s.order( SBIClient::FX::MURJPY, SBIClient::FX::SELL, 1, {
          :rate=>@rates[SBIClient::FX::MURJPY].ask_rate + 0.5,
          :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_LIMIT_ORDER,
          :expiration_type=>SBIClient::FX::EXPIRATION_TYPE_TODAY,
          :settle => {
            :rate=>@rates[SBIClient::FX::MURJPY].ask_rate - 1,
            :execution_expression=>SBIClient::FX::EXECUTION_EXPRESSION_REVERSE_LIMIT_ORDER
          }
        })
    }.should raise_error( RuntimeError )
  end
end