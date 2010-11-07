# -*- coding: utf-8 -*- 

# ※「../etc/auth.yaml」を作成し、以下の内容を設定しておくこと。
# <pre>
# ---
# user: <SBI証券のアクセスユーザー名>
# pass: <SBI証券のアクセスユーザーパスワード>
# order_pass: <SBI証券の取引パスワード>
# </pre>
require 'yaml'

auth = YAML.load_file "#{File.dirname(__FILE__)}/../etc/auth.yaml"
USER=auth["user"]
PASS=auth["pass"]
ORDER_PASS=auth["order_pass"]# 取引パスワード

#注文一覧を出力する。
#session:: Session
def print_order( session )
  # 注文一覧を取得
  orders = session.list_orders
  orders.each_pair {|k,v|
   puts <<-STR
---
order_no : #{v.order_no} 
trade_type : #{v.trade_type}
order_type : #{v.order_type}
execution_expression : #{v.execution_expression} 
sell_or_buy : #{v.sell_or_buy} 
pair : #{v.pair}
count : #{v.count} 
rate : #{v.rate} 
order_state : #{v.order_state}

STR
  }
end