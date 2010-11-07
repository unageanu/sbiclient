# -*- coding: utf-8 -*- 

$: << "."
$: << "../lib"

require 'sbiclient'
require 'common'

# ログイン
c = SBIClient::Client.new
c.fx_session( USER, PASS, ORDER_PASS ) {|session|

  # 建玉一覧を取得
  rates = session.list_positions
  rates.each_pair {|k,v|
    puts "#{v.pair} : #{v.sell_or_buy} : #{v.count} : #{v.rate} : #{v.profit_or_loss} : #{v.date}"
  }
  
}