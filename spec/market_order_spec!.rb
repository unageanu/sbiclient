$: << "../lib"

require 'sbiclient'
require 'common'

# 成り行きで発注および決済を行うテスト。
# <b>注意:</b> 決済まで行う為、実行すると資金が減少します。
describe "market order" do
  it_should_behave_like "login"   
  
  it "成り行きで発注し決済するテスト" do
    prev = @s.list_positions
    
    # 成り行きで注文
    @s.order( SBIClient::FX::MSDJPY, SBIClient::FX::BUY, 1, {
      :expiration_type=>SBIClient::FX::EXPIRATION_TYPE_TODAY
    })
    @s.order( SBIClient::FX::MSDJPY, SBIClient::FX::SELL, 1, {
      :expiration_type=>SBIClient::FX::EXPIRATION_TYPE_WEEK_END
    })
    sleep 1
    
    #建玉一覧取得
    after = @s.list_positions
    positions = after.find_all {|i| !prev.include?(i[0]) }.map{|i| i[1] }
    positions.length.should == 2 # 新規の建玉が2つ存在することを確認
    positions.each {|p|
      p.position_id.should_not be_nil
      p.pair.should_not be_nil
      p.sell_or_buy.should_not be_nil
      p.count.should == 1
      p.rate.should_not be_nil
      p.profit_or_loss.should_not be_nil
      p.date.should_not be_nil
    }
    
    # 決済注文
    positions =  after.map{|i| i[1] }
    positions.each {|p| 
      @s.settle( p[0] ) if p[0] =~ /MURJPY/
    }
    sleep 1
    after_settle =  @s.list_positions
    assert_false after_settle.key?( positions[0] )
    assert_false after_settle.key?( positions[1] )
  end
end
