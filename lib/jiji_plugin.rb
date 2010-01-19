
require 'rubygems'
require 'jiji/plugin/securities_plugin'
require 'sbiclient'
require 'thread'

# SBI証券アクセスプラグイン
class SBISecuritiesPlugin
  include JIJI::Plugin::SecuritiesPlugin
  
  #プラグインの識別子を返します。
  def plugin_id
    :sbi_securities
  end
  #プラグインの表示名を返します。
  def display_name
    "SBI Securities"
  end
  #「jiji setting」でユーザーに入力を要求するデータの情報を返します。
  def input_infos
    [ Input.new( :user, "Please input a user name of SBI Securities.", false, nil ),
      Input.new( :password, "Please input a password of SBI Securities.", true, nil ),
      Input.new( :trade_password, "Please input a trade password of SBI Securities.", true, nil ),
      Input.new( :proxy, "Please input a proxy. example: http://example.com:80 (default: nil )", false, nil ) ]
  end
  
  #プラグインを初期化します。
  def init_plugin( props, logger ) 
    @session = SBISecuritiesPluginSession.new( props, logger )
  end
  #プラグインを破棄します。
  def destroy_plugin
    @session.close
  end
  
  #利用可能な通貨ペア一覧を取得します。
  def list_pairs
    return ALL_PAIRS.map {|pair|
      count = 10000
      if pair == SBIClient::FX::MSDJPY \
          || pair == SBIClient::FX::MURJPY \
          || pair == SBIClient::FX::MBPJPY \
          || pair == SBIClient::FX::MUDJPY \
          || pair == SBIClient::FX::MZDJPY
          count = 1000 
      elsif pair == SBIClient::FX::ZARJPY 
          count = 100000
      end
      Pair.new( pair, count )
    }
  end
  
  #現在のレートを取得します。
  def list_rates
    @session.list_rates.inject({}) {|r,p|
        r[p[0]] = Rate.new( p[1].bid_rate, p[1].ask_rate, p[1].sell_swap, p[1].buy_swap )
        r
    }
  end
  
  #成り行きで発注を行います。
  def order( pair, sell_or_buy, count )
    
    # 建玉一覧を取得
    before = @session.list_positions.inject( Set.new ) {|s,i| s << i[0]; s }
    # 発注
    @session.order( pair, sell_or_buy == :buy ? SBIClient::FX::BUY : SBIClient::FX::SELL,  count )
    # 建玉を特定
    position = nil
    # 10s待っても取得できなければあきらめる
    20.times {|i|
      sleep 0.5
      position = @session.list_positions.find {|i| !before.include?(i[0]) }
      break if position
    }
    raise "order fialed." unless position
    return JIJI::Plugin::SecuritiesPlugin::Position.new( position[1].position_id )
  end
  
  #建玉を決済します。
  def commit( position_id, count )
    @session.settle( position_id, count )
  end

private 
  
  ALL_PAIRS =  [
    SBIClient::FX::USDJPY, SBIClient::FX::EURJPY,
    SBIClient::FX::GBPJPY, SBIClient::FX::AUDJPY,
    SBIClient::FX::NZDJPY, SBIClient::FX::CADJPY,
    SBIClient::FX::CHFJPY, SBIClient::FX::ZARJPY,
    SBIClient::FX::EURUSD, SBIClient::FX::GBPUSD,
    SBIClient::FX::AUDUSD, SBIClient::FX::NOKJPY,
    SBIClient::FX::MUDJPY, SBIClient::FX::HKDJPY,
    SBIClient::FX::SEKJPY, SBIClient::FX::MZDJPY,
    SBIClient::FX::KRWJPY, SBIClient::FX::PLNJPY,
    SBIClient::FX::MARJPY, SBIClient::FX::SGDJPY,
    SBIClient::FX::MSDJPY, SBIClient::FX::MXNJPY,
    SBIClient::FX::MURJPY, SBIClient::FX::TRYJPY,
    SBIClient::FX::MBPJPY, SBIClient::FX::CNYJPY
  ]
end

class SBISecuritiesPluginSession
  def initialize( props, logger ) 
    @props = props
    @logger = logger
    @m = Mutex.new
  end
  def method_missing( name, *args )
    @m.synchronize { 
      begin
        session.send( name, *args )
      rescue
        # エラーになった場合はセッションを再作成する
        close
        
        # セッションタイムアウトの場合1回だけリトライ
        if $!.to_s == "session-time-out"
          @logger.warn "session time out. retry..."
          begin
            session.send( name, *args )
          rescue
            close
            raise $!
          end
        else
          raise $!
        end
      end
    }
  end
  def close
    begin
      @session.logout if @session
    rescue
      @logger.error $!
    ensure
      @session = nil
      @client = nil
    end
  end
  def session
    begin
      proxy = nil
      if @props.key?(:proxy) && @props[:proxy] != nil && @props[:proxy].length > 0
        proxy = @props[:proxy]
      end
      @client ||= SBIClient::Client.new( proxy )
      @session ||= @client.fx_session( @props[:user], @props[:password], @props[:trade_password] )
    rescue
      @logger.error $!
      raise $!
    end
    @session
  end
end

JIJI::Plugin.register( 
  JIJI::Plugin::SecuritiesPlugin::FUTURE_NAME, 
  SBISecuritiesPlugin.new )

