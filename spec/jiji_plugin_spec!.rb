#!/usr/bin/ruby

$: << "../lib"

require "rubygems"
require "logger"
require 'sbiclient'
require "common"
require 'jiji/plugin/plugin_loader'
require 'jiji/plugin/securities_plugin'

# jijiプラグインのテスト
# ※実際に取引を行うので注意!
describe "market order" do
  before(:all) {
    # ロード
    JIJI::Plugin::Loader.new.load
    plugins = JIJI::Plugin.get( JIJI::Plugin::SecuritiesPlugin::FUTURE_NAME )
    @plugin = plugins.find {|i| i.plugin_id == :sbi_securities }
    @logger = Logger.new STDOUT
  } 
  it "jiji pluginのテスト" do
    @plugin.should_not be_nil
    @plugin.display_name.should == "SBI Securities"
    
    begin
      @plugin.init_plugin( {:user=>USER, :password=>PASS, :trade_password=>ORDER_PASS}, @logger )
      
      # 利用可能な通貨ペア一覧とレート
      pairs = @plugin.list_pairs
      rates =  @plugin.list_rates
      pairs.each {|p|
        # 利用可能とされたペアのレートが取得できていることを確認
        p.name.should_not be_nil
        p.trade_unit.should_not be_nil
        rates[p.name].should_not be_nil
        rates[p.name].bid.should_not be_nil
        rates[p.name].ask.should_not be_nil
        rates[p.name].sell_swap.should_not be_nil
        rates[p.name].buy_swap.should_not be_nil
      }
      sleep 1
      
      3.times {
        rates =  @plugin.list_rates
        pairs.each {|p|
          # 利用可能とされたペアのレートが取得できていることを確認
          p.name.should_not be_nil
          p.trade_unit.should_not be_nil
          rates[p.name].should_not be_nil
          rates[p.name].bid.should_not be_nil
          rates[p.name].ask.should_not be_nil
          rates[p.name].sell_swap.should_not be_nil
          rates[p.name].buy_swap.should_not be_nil
        }
        sleep 3
      }
      
      # 売り/買い
      sell = @plugin.order( :MSDJPY, :sell, 1 )      
      buy  = @plugin.order( :MSDJPY, :buy, 1 ) 
      sell.position_id.should_not be_nil
      buy.position_id.should_not be_nil
      
      # 約定
      @plugin.commit sell.position_id, 1 
      @plugin.commit buy.position_id, 1
    ensure
      @plugin.destroy_plugin
    end
  end
end