begin
  require 'rubygems'
rescue LoadError
end
require 'mechanize'
require 'date'
require 'kconv'
require 'set'

#
#=== SBI証券アクセスクライアント
#
#*License*::   Ruby ライセンスに準拠
#
#SBI証券を利用するためのクライアントライブラリです。携帯向けサイトのスクレイピングにより以下の機能を提供します。
#- 外為証拠金取引(FX)取引
#
#====基本的な使い方
#
# require 'sbiclient'
# 
# c = SBIClient::Client.new 
# # c = SBIClient::Client.new https://<プロキシホスト>:<プロキシポート> # プロキシを利用する場合
# c.fx_session( "<ユーザー名>", "<パスワード>" ) { | fx_session |
#   # 通貨ペア一覧取得
#   list = fx_session.list_rates
#   puts list
# } 
#
#====免責
#- 本ライブラリの利用は自己責任でお願いします。
#- ライブラリの不備・不具合等によるあらゆる損害について、作成者は責任を負いません。
#
module SBIClient

  # クライアント
  class Client
    # ホスト名
    DEFAULT_HOST_NAME = "https://mobile.sbisec.co.jp/web/visitor/loginUser.do"

    #
    #===コンストラクタ
    #
    #*proxy*:: プロキシホストを利用する場合、そのホスト名とパスを指定します。
    # 例) https://proxyhost.com:80
    #
    def initialize( proxy=nil )
      @client = WWW::Mechanize.new {|c|
        # プロキシ
        if proxy 
          uri = URI.parse( proxy )
          c.set_proxy( uri.host, uri.port )
        end
      }
      @client.keep_alive = false
      @client.max_history=0
      WWW::Mechanize::AGENT_ALIASES["KDDI-CA39"] = \
        'KDDI-CA39 UP.Browser/6.2.0.13.1.5 (GUI) MMP/2.0'
      @client.user_agent_alias = "KDDI-CA39"
      @host_name = DEFAULT_HOST_NAME
    end

    #ログインし、セッションを開始します。
    #-ブロックを指定した場合、引数としてセッションを指定してブロックを実行します。ブロック実行後、ログアウトします。
    #-そうでない場合、セッションを返却します。この場合、SBIClient::FX::FxSession#logoutを実行しログアウトしてください。
    #
    #userid:: ユーザーID
    #password:: パスワード
    #options:: オプション 
    #戻り値:: SBIClient::FX::FxSession
    def fx_session( userid, password, options={}, &block )
      # ログイン
      page = @client.get(@host_name)
      SBIClient::Client.error(page)  if page.forms.length <= 0
      form = page.forms.first
      form.username = userid
      form.password = password
      result = @client.submit(form, form.buttons.first) 
      SBIClient::Client.error(result)  unless result.title.toutf8 =~ /SBI証券.*メンバートップ/
      session = FX::FxSession.new( @client, result, options )
      if block_given?
        begin
          yield session
        ensure
          session.logout
        end
      else
        return session
      end
    end
    def self.error( page )
        msgs = page.body.scan( /<font color="#FF0000">([^<]*)</ ).flatten
        error = !msgs.empty? ? msgs.map{|m| m.strip}.join(",") : page.body
        raise "operation failed.detail=#{error}".toutf8 
    end
    
    #ホスト名
    attr :host_name, true  
  end
  
  module FX
    
    # 通貨ペア: 米ドル-円
    USDJPY = :USDJPY
    # 通貨ペア: ユーロ-円
    EURJPY = :EURJPY
    # 通貨ペア: イギリスポンド-円
    GBPJPY = :GBPJPY
    # 通貨ペア: 豪ドル-円
    AUDJPY = :AUDJPY
    # 通貨ペア: ニュージーランドドル-円
    NZDJPY = :NZDJPY
    # 通貨ペア: カナダドル-円
    CADJPY = :CADJPY
    # 通貨ペア: スイスフラン-円
    CHFJPY = :CHFJPY
    # 通貨ペア: 南アランド-円
    ZARJPY = :ZARJPY
    # 通貨ペア: ユーロ-米ドル
    EURUSD = :EURUSD
    # 通貨ペア: イギリスポンド-米ドル
    GBPUSD = :GBPUSD
    # 通貨ペア: 豪ドル-米ドル
    AUDUSD = :AUDUSD
    # 通貨ペア: NWクローネ-円
    NOKJPY = :NOKJPY
    # 通貨ペア: ミニ豪ドル-円
    MUDJPY = :MUDJPY
    # 通貨ペア: 香港ドル-円
    HKDJPY = :HKDJPY
    # 通貨ペア: SWクローナ-円
    SEKJPY = :SEKJPY
    # 通貨ペア: ミニNZドル-円
    MZDJPY = :MZDJPY
    # 通貨ペア: ウォン-円
    KRWJPY = :KRWJPY
    # 通貨ペア: PLズロチ-円
    PLNJPY = :PLNJPY
    # 通貨ペア: ミニ南アランド-円
    MARJPY = :MARJPY
    # 通貨ペア: SGPドル-円
    SGDJPY = :SGDJPY
    # 通貨ペア: ミニ米ドル-円
    MSDJPY = :MSDJPY
    # 通貨ペア: メキシコペソ-円
    MXNJPY = :MXNJPY
    # 通貨ペア: ミニユーロ-円
    MURJPY = :MURJPY
    # 通貨ペア: トルコリラ-円
    TRYJPY = :TRYJPY
    # 通貨ペア: ミニポンド-円
    MBPJPY = :MBPJPY
    # 通貨ペア: 人民元-円
    CNYJPY = :CNYJPY

    # 売買区分: 買い
    BUY = 0
    # 売買区分: 売り
    SELL = 1

    
    #=== FX取引のためのセッションクラス
    #Client#fx_sessionのブロックの引数として渡されます。詳細はClient#fx_sessionを参照ください。
    class FxSession
      
      def initialize( client, top_page, options={} )
        @client = client
        @options = options
        
        # FXのトップ画面へ
        form = top_page.forms.first
        form.product_group = "sbi_fx_alpha"
        result = @client.submit(form, form.buttons.first) 
        SBIClient::Client.error(result)  unless result.content.toutf8 =~ /SBI FX α/
        @links = result.links
      end
      
      #====レート一覧を取得します。
      #
      #戻り値:: 通貨ペアをキーとするSBIClient::FX::Rateのハッシュ。
      def list_rates
        #スワップの定期取得
        if !@last_update_time_of_swaps \
           || Time.now.to_i - @last_update_time_of_swaps  > (@options[:swap_update_interval] || 60*60)
          @swaps  = list_swaps
          @last_update_time_of_swaps = Time.now.to_i
        end
        rates = {}
        each_rate_page {|page|
          collect_rate( page, rates ) 
        } 
        return rates
      end
    
      #====スワップの一覧を取得します。
      #
      #戻り値:: 通貨ペアをキーとするSBIClient::FX::Swapのハッシュ。
      def list_swaps 
        swap = {}
        each_rate_page {|page|
          collect_swap( page, swap ) 
        } 
        return swap
      end
      
      # ログアウトします。
      def logout
        link_click( "*" )
      end
      
    private
      #レートページを列挙します
      def each_rate_page( &block ) #:nodoc:
        result = link_click( "1" )
        block.call( result ) if block_given?
        result.links.each {|i|
          next unless i.text =~ /^\d+$/ 
          res = @client.click( i )
          block.call( res ) if block_given?
        }
      end
      
      #ページからレート情報を収集します
      def collect_rate( page, map )  #:nodoc:
        tokens = page.body.toutf8.scan( RATE_REGEX )
        tokens.each {|t|
          next unless t[0] =~ /\&meigaraId\=([A-Z\/]+)&/ 
          pair = FxSession.to_pair( $1 )
          swap = @swaps[pair]
          rate = FxSession.convert_rate t[2]
          if ( rate && swap )
            map[pair]  = Rate.new( pair, rate[0], rate[1], swap.sell_swap, swap.buy_swap ) 
          end
        }
      end
      RATE_REGEX = /◇<A([^>]*)>([^<]*)<\/A>\s*<BR>\s*<CENTER>\s*<B>\s*([\d\-_\.]+)\s*<\/B>\s*<\/CENTER>/
      
      #12.34-12.35 形式の文字列をbidレート、askレートに変換します。
      def self.convert_rate( str ) #:nodoc:
        if str =~ /([\d.]+)\-([\d.]+)/
             return [$1.to_f,$2.to_f]
        end
      end
      
      #ページからスワップ情報を収集します
      def collect_swap( page, map )   #:nodoc:
        page.links.each {|i|
          next unless i.href =~ /\&meigaraId\=([A-Z\/]+)&/
          pair = FxSession.to_pair( $1 )
          res = @client.click( i )
          next unless res.body.toutf8 =~ /SW売\/買\(円\)\:<BR>\s*([\-\d]*)\/([\-\d]*)\s*</
          map[pair] = Swap.new( pair, $1.to_i, $2.to_i )
        }
      end
    
      # "USD/JPY"を:USDJPYのようなシンボルに変換します。
      def self.to_pair( str )  #:nodoc:
        str.gsub( /\//, "" ).to_sym
      end
     
      def link_click( no )
        link = @links.find {|i|
            i.attributes["accesskey"] == no
        }
        raise "link isnot found. accesskey=#{no}"  unless link
        @client.click( link )
      end
    end
    
    # オプション
    attr :options, true
    
    #=== スワップ
    Swap = Struct.new(:pair, :sell_swap, :buy_swap)
    #=== レート
    Rate = Struct.new(:pair, :bid_rate, :ask_rate, :sell_swap, :buy_swap )
    
  end
end



