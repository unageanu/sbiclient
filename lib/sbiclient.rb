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
#   # レート情報一覧取得
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
    #order_password:: 取引パスワード
    #options:: オプション 
    #戻り値:: SBIClient::FX::FxSession
    def fx_session( userid, password, order_password, options={}, &block )
      # ログイン
      page = @client.get(@host_name)
      SBIClient::Client.error(page)  if page.forms.length <= 0
      form = page.forms.first
      form.username = userid
      form.password = password
      result = @client.submit(form, form.buttons.first) 
      SBIClient::Client.error(result)  unless result.title.toutf8 =~ /SBI証券.*メンバートップ/
      session = FX::FxSession.new( @client, order_password, result, options )
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
        msgs = page.body.scan( /<[fF][oO][nN][tT]\s+[cC][oO][lL][oO][rR]="?#FF0000"?>([^<]*)</ ).flatten
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
    BUY = :BUY
    # 売買区分: 売り
    SELL = :SELL

    # 注文タイプ: 成行
    ORDER_TYPE_MARKET_ORDER = :MARKET_ORDER
    # 注文タイプ: 通常
    ORDER_TYPE_NORMAL = :NORMAL
    # 注文タイプ: IFD
    ORDER_TYPE_IFD = :IFD
    # 注文タイプ: OCO
    ORDER_TYPE_OCO = :OCO
    # 注文タイプ: IFD-OCO
    ORDER_TYPE_IFD_OCO = :IFD_OCO
    # 注文タイプ: とレール
    ORDER_TYPE_TRAIL = :TRAIL

    # 有効期限: 当日限り
    EXPIRATION_TYPE_TODAY = :EXPIRATION_TYPE_TODAY
    # 有効期限: 週末まで
    EXPIRATION_TYPE_WEEK_END = :EXPIRATION_TYPE_WEEK_END
    # 有効期限: 日付指定
    EXPIRATION_TYPE_SPECIFIED = :EXPIRATION_TYPE_SPECIFIED
    
    # 執行条件: 成行
    EXECUTION_EXPRESSION_MARKET_ORDER = :MARKET_ORDER
    # 執行条件: 指値
    EXECUTION_EXPRESSION_LIMIT_ORDER = :LIMIT_ORDER
    # 執行条件: 逆指値
    EXECUTION_EXPRESSION_REVERSE_LIMIT_ORDER = :REVERSE_LIMIT_ORDER
    
    # トレード種別: 新規
    TRADE_TYPE_NEW = :TRADE_TYPE_NEW
    # トレード種別: 決済
    TRADE_TYPE_SETTLEMENT = :TRADE_TYPE_SETTLEMENT
    
    #=== FX取引のためのセッションクラス
    #Client#fx_sessionのブロックの引数として渡されます。詳細はClient#fx_sessionを参照ください。
    class FxSession
      
      def initialize( client, order_password, top_page, options={} )
        @client = client
        @order_password = order_password
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
      
      #=== 注文一覧を取得します。
      #
      #戻り値:: 注文番号をキーとするClickClientScrap::FX::Orderのハッシュ。
      #
      def list_orders(  )
        result =  link_click( "4" ) 
        
        # TODO 2ページ目以降を参照してない・・・
        #puts result.body.toutf8
        list = result.body.toutf8.scan( /<A href="[^"]*&meigaraId=([a-zA-Z0-9\/]*)[^"]*">[^<]*<\/A>\s*<BR>\s*受付時間:<BR>\s*([^<]*)<BR>\s*注文パターン:([^<]+)<BR>\s*([^<]+)<BR>\s*注文番号:(\d+)<BR>\s*注文価格:([^<]+)<BR>\s*約定価格:([^<]*)<BR>\s*数量\(未約定\):<BR>\s*(\d+)\(\d+\)単位<BR>\s*発注状況:([^<]*)<BR>/)
        tmp = {}
        list.each {|i|
          pair = to_pair( i[0] )
          order_type = to_order_type_code(i[2])
          trade_type = i[3] =~ /^新規.*/ ? SBIClient::FX::TRADE_TYPE_NEW : SBIClient::FX::TRADE_TYPE_SETTLEMENT
          sell_or_buy = i[3] =~ /.*売\/.*/ ?  SBIClient::FX::SELL : SBIClient::FX::BUY 
          execution_expression = if i[3] =~ /.*\/指値/
            SBIClient::FX::EXECUTION_EXPRESSION_LIMIT_ORDER
          elsif i[3] =~ /.*\/逆指値/
            SBIClient::FX::EXECUTION_EXPRESSION_REVERSE_LIMIT_ORDER
          else
            SBIClient::FX::EXECUTION_EXPRESSION_MARKET_ORDER
          end
          order_no = i[4] 
          rate =  i[5].to_f
          count =  i[7].to_i
          
          tmp[order_no] = Order.new( order_no, trade_type, order_type, 
              execution_expression, sell_or_buy, pair, count, rate, i[8])
        }
        return tmp
      end
      
      #
      #===注文を行います。
      #
      #currency_pair_code:: 通貨ペアコード(必須)
      #sell_or_buy:: 売買区分。SBIClient::FX::BUY,SBIClient::FX::SELLのいずれかを指定します。(必須)
      #unit:: 取引数量(必須)
      #options:: 注文のオプション。注文方法に応じて以下の情報を設定できます。
      #            - <b>成り行き注文</b>※未実装
      #              - なし
      #            - <b>通常注文</b> ※注文レートが設定されていれば通常取引となります。
      #              - <tt>:rate</tt> .. 注文レート(必須)
      #              - <tt>:execution_expression</tt> .. 執行条件。SBIClient::FX::EXECUTION_EXPRESSION_LIMIT_ORDER等を指定します(必須)
      #              - <tt>:expiration_type</tt> .. 有効期限。SBIClient::FX::EXPIRATION_TYPE_TODAY等を指定します(必須)
      #              - <tt>:expiration_date</tt> .. 有効期限が「日付指定(SBIClient::FX::EXPIRATION_TYPE_SPECIFIED)」の場合の有効期限をDateで指定します。(有効期限が「日付指定」の場合、必須)
      #            - <b>OCO注文</b> ※2つめの取引レートと2つめの取引種別が設定されていればOCO取引となります。
      #              - <tt>:rate</tt> .. 注文レート(必須)
      #              - <tt>:execution_expression</tt> .. 執行条件。SBIClient::FX::EXECUTION_EXPRESSION_LIMIT_ORDER等を指定します(必須)
      #              - <tt>:second_order_sell_or_buy</tt> .. 2つめの取引種別(必須) ※1つめの取引種別と同じ値にすると2つめの注文は逆指値になります。同じでなければ両者とも指値になります。
      #              - <tt>:second_order_rate</tt> .. 2つめの取引レート(必須)
      #              - <tt>:expiration_type</tt> .. 有効期限。SBIClient::FX::EXPIRATION_TYPE_TODAY等を指定します(必須)
      #              - <tt>:expiration_date</tt> .. 有効期限が「日付指定(SBIClient::FX::EXPIRATION_TYPE_SPECIFIED)」の場合の有効期限をDateで指定します。(有効期限が「日付指定」の場合、必須)
      #            - <b>IFD注文</b> ※決済取引の指定があればIFD取引となります。
      #              - <tt>:rate</tt> .. 注文レート(必須)
      #              - <tt>:execution_expression</tt> .. 執行条件。SBIClient::FX::EXECUTION_EXPRESSION_LIMIT_ORDER等を指定します(必須)
      #              - <tt>:expiration_type</tt> .. 有効期限。SBIClient::FX::EXPIRATION_TYPE_TODAY等を指定します(必須)
      #              - <tt>:expiration_date</tt> .. 有効期限が「日付指定(SBIClient::FX::EXPIRATION_TYPE_SPECIFIED)」の場合の有効期限をDateで指定します。(有効期限が「日付指定」の場合、必須)
      #              - <tt>:settle</tt> .. 決済取引の指定。マップで指定します。
      #                - <tt>:rate</tt> .. 決済取引の注文レート(必須)
      #                - <tt>:execution_expression</tt> .. 決済取引の執行条件。SBIClient::FX::EXECUTION_EXPRESSION_LIMIT_ORDER等を指定します(必須)
      #            - <b>IFD-OCO注文</b> ※決済取引の指定と逆指値レートの指定があればIFD-OCO取引となります。
      #              - <tt>:rate</tt> .. 注文レート(必須)
      #              - <tt>:execution_expression</tt> .. 執行条件。SBIClient::FX::EXECUTION_EXPRESSION_LIMIT_ORDER等を指定します(必須)
      #              - <tt>:expiration_type</tt> .. 有効期限。SBIClient::FX::EXPIRATION_TYPE_TODAY等を指定します(必須)
      #              - <tt>:expiration_date</tt> .. 有効期限が「日付指定(SBIClient::FX::EXPIRATION_TYPE_SPECIFIED)」の場合の有効期限をDateで指定します。(有効期限が「日付指定」の場合、必須)
      #              - <tt>:settle</tt> .. 決済取引の指定。マップで指定します。
      #                - <tt>:rate</tt> .. 決済取引の注文レート(必須)
      #                - <tt>:stop_order_rate</tt> .. 決済取引の逆指値レート(必須)
      #            - <b>トレール注文</b> ※トレール幅の指定があればトレール取引となります。
      #              - <tt>:rate</tt> .. 注文レート(必須) ※他の注文条件と違って<b>執行条件は逆指値で固定</b>です。
      #              - <tt>:expiration_type</tt> .. 有効期限。SBIClient::FX::EXPIRATION_TYPE_TODAY等を指定します(必須)
      #              - <tt>:expiration_date</tt> .. 有効期限が「日付指定(SBIClient::FX::EXPIRATION_TYPE_SPECIFIED)」の場合の有効期限をDateで指定します。(有効期限が「日付指定」の場合、必須)
      #              - <tt>:trail_range</tt> .. トレール幅(必須)
      #戻り値:: SBIClient::FX::OrderResult
      #
      def order ( currency_pair_code, sell_or_buy, unit, options={} )
        
        # 取り引き種別の判別とパラメータチェック
        type = ORDER_TYPE_MARKET_ORDER
        if ( options && options[:settle] != nil  )
          if ( options[:settle][:stop_order_rate] != nil)
             # 逆指値レートと決済取引の指定があればIFD-OCO取引
             raise "options[:settle][:rate] is required." unless options[:settle][:rate]
             type = ORDER_TYPE_IFD_OCO
          else
             # 決済取引の指定のみがあればIFD取引
             raise "options[:settle][:rate] is required." unless options[:settle][:rate]
             raise "options[:settle][:execution_expression] is required." unless options[:settle][:execution_expression]
             type = ORDER_TYPE_IFD
          end
          raise "options[:rate] is required." unless options[:rate]
          raise "options[:execution_expression] is required." unless options[:execution_expression]
          raise "options[:expiration_type] is required." unless options[:expiration_type]
        elsif ( options && options[:rate] != nil )
          if ( options[:second_order_rate] != nil && options[:second_order_sell_or_buy] != nil  )
            # 逆指値レートが指定されていればOCO取引
            raise "options[:execution_expression] is required." unless options[:execution_expression]
            type = ORDER_TYPE_OCO
          elsif ( options[:trail_range] != nil )
            # トレール幅が指定されていればトレール取引
            type = ORDER_TYPE_TRAIL
          else
            # そうでなければ通常取引
            type = ORDER_TYPE_NORMAL
            raise "options[:execution_expression] is required." unless options[:execution_expression]
          end
          raise "options[:expiration_type] is required." unless options[:expiration_type]
        else
          # 成り行き
          type = ORDER_TYPE_MARKET_ORDER
        end
        
        #新規注文
        result =  link_click( "2" )
        SBIClient::Client.error( result ) if result.forms.empty?
        form = result.forms.first
        form.meigaraId =  currency_pair_code.to_s.insert(3, "/").to_sym
        form.radiobuttons_with("urikai").each {|b|
          b.check if b.value == ( sell_or_buy == SBIClient::FX::BUY ? "1" : "-1" )
        }
        
        # 詳細設定画面へ
        result = @client.submit(form) 
        SBIClient::Client.error( result ) if result.forms.empty?
        form = result.forms.first
        case type
          when ORDER_TYPE_MARKET_ORDER
            # 成り行き
            form.sikkouJyouken = "0"
          when ORDER_TYPE_NORMAL
            # 指値
            set_expression( form, options[:execution_expression] ) 
            set_rate(form, options[:rate])
            set_expiration( form,  options ) # 有効期限
          when ORDER_TYPE_OCO
            # OCO
            form.order = "3"
            result = @client.submit(form, form.buttons.find {|b| b.value=="選択" } ) 
            form = result.forms.first
            set_expression( form, options[:execution_expression] ) 
            set_rate(form, options[:rate])
            form["urikai2"] = ( options[:second_order_sell_or_buy] == SBIClient::FX::BUY ? "1" : "-1" )
            result = @client.submit(form, form.buttons.find {|b| b.value=="次へ" }) 
            form = result.forms.first
            SBIClient::Client.error( result ) unless result.body.toutf8 =~ /maisuu/
            set_rate(form, options[:second_order_rate], "2")
            set_expiration( form,  options ) # 有効期限
          when ORDER_TYPE_IFD
            # IFD
            form.order = "2"
            result = @client.submit(form, form.buttons.find {|b| b.value=="選択" }) 
            form = result.forms.first
            set_expression( form, options[:execution_expression] ) 
            set_rate(form, options[:rate], "3")
            set_expression( form, options[:settle][:execution_expression], "sikkouJyouken2" ) 
            set_rate(form, options[:settle][:rate], "1")
            set_expiration( form,  options ) # 有効期限
          when ORDER_TYPE_IFD_OCO
            form.order = "4"
            set_expression( form, options[:execution_expression] ) 
            set_rate(form, options[:rate], "3")
            set_expression( form, options[:settle][:execution_expression], "sikkouJyouken2" ) 
            set_rate(form, options[:settle][:rate], "1")
            set_rate(form, options[:settle][:stop_order_rate], "2")
            set_expiration( form,  options ) # 有効期限
          when ORDER_TYPE_TRAIL
            form.order = "6"
            set_rate(form, options[:rate], "1")
            set_trail(form, options[:trail_range])
            set_expiration( form,  options ) # 有効期限
          else
            raise "unknown order type."
        end
        form.maisuu = unit.to_s
        form["postTorihikiPs"] = @order_password
                
        # 確認画面へ
        result = @client.submit( form, form.buttons.find {|b| b.value=="注文確認" } ) 
        SBIClient::Client.error( result ) unless result.body.toutf8 =~ /注文確認/

        result = @client.submit(result.forms.first)
        SBIClient::Client.error( result ) unless result.body.toutf8 =~ /注文番号\:[^\d]+(\d+)/
        return OrderResult.new( $1 )
      end
      
      #
      #=== 注文をキャンセルします。
      #
      #order_no:: 注文番号
      #戻り値:: なし
      #
      def cancel_order( order_no ) 
        
        raise "order_no is nil." unless order_no
        
        # 注文一覧
        result =  link_click( "4" )
        SBIClient::Client.error( result ) if result.links.empty?
        
        # 対象となる注文をクリック 
        link =  result.links.find {|l|
            l.href =~ /[^"]*Id=([\d]+)[^"]*/ && $1 == order_no
        }
        raise "illegal order_no. order_no=#{order_no}" unless link
        result =  @client.click(link)
        SBIClient::Client.error( result ) if result.forms.empty?
        
        # キャンセル
        form = result.forms.first
        form.radiobuttons_with("tkF").each{|b|  
          b.check if b.value == "kesi"
        }
        result = @client.submit(form)
        SBIClient::Client.error( result ) unless result.body.toutf8 =~ /注文確認/
        form = result.forms.first
        form.ToriPs = @order_password
        result = @client.submit(form, form.buttons.find {|b| b.value=="注文取消" })
        SBIClient::Client.error( result ) unless result.body.toutf8 =~ /取消を受付致しました/
      end
      
      #===ログアウトします。
      def logout
        link_click( "*" )
      end
      
    private
      # フォームに執行条件を設定します。
      def set_expression( form, exp, key="sikkouJyouken" ) #:nodoc:
        form[key] = exp  == SBIClient::FX::EXECUTION_EXPRESSION_REVERSE_LIMIT_ORDER ? "2" : "1" #指値/逆指値
      end
      # フォームにトレール幅を設定します。
      def set_trail(form, trail, index=1)  #:nodoc:
          raise "illegal trail. trail=#{trail}" unless trail.to_s =~ /(\d+)(\.\d*)?/
          form["trail#{index}_1"] = $1
          form["trail#{index}_2"] = $2[1..$2.length] if $2
      end
      # フォームにレートを設定します。
      def set_rate(form, rate, index=1)  #:nodoc:
          raise "illegal rate. rate=#{rate}" unless rate.to_s =~ /(\d+)(\.\d*)?/
          form["sasine#{index}_1"] = $1
          form["sasine#{index}_2"] = $2[1..$2.length] if $2
      end
    
      # 注文種別を注文種別コードに変換します。
      def to_order_type_code( order_type )
        return  case order_type
          when "成行"
            SBIClient::FX::ORDER_TYPE_MARKET_ORDER
          when "通常"
            SBIClient::FX::ORDER_TYPE_NORMAL
          when "OCO1"
            SBIClient::FX::ORDER_TYPE_OCO
          when "OCO2"
            SBIClient::FX::ORDER_TYPE_OCO
          when "IFD1"
            SBIClient::FX::ORDER_TYPE_IFD
          when "IFD2"
            SBIClient::FX::ORDER_TYPE_IFD
          when "IFD-OCO"
            SBIClient::FX::ORDER_TYPE_IFD_OCO
          else
            raise "illegal order_type. order_type=#{order_type}"
        end
      end
    
      # "USD/JPY"を:USDJPYのようなシンボルに変換します。
      def to_pair( str ) #:nodoc:
        str.gsub( /\//, "" ).to_sym
      end
    
      # 有効期限を設定します。
      def set_expiration( form,  options ) #:nodoc:
        date = nil
        case options[:expiration_type]
          when SBIClient::FX::EXPIRATION_TYPE_TODAY
            # デフォルトを使う
            return
          when SBIClient::FX::EXPIRATION_TYPE_WEEK_END
            date = DateTime.now + 7
          when SBIClient::FX::EXPIRATION_TYPE_SPECIFIED
            raise "options[:expiration_date] is required." unless options[:expiration_date]
            date = options[:expiration_date]
          else
            return
        end
        return unless date
        form["yuukou_kigen_date"] = date.strftime("%Y/%m/%d")
        if date.kind_of?(DateTime)
          form["yuukou_kigen_jikan"] = sprintf("%02d", date.hour )
          form["yuukou_kigen_fun"] = sprintf("%02d", date.min )
        end
      end
    
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
    #===注文結果
    OrderResult = Struct.new(:order_no )
    #===注文
    Order = Struct.new(:order_no, :trade_type, :order_type, :execution_expression, :sell_or_buy, :pair,  :count, :rate, :order_state )
  end
end



