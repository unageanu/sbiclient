
# ※sample.rbと同じディレクトリにuser,passファイルを作成し、
#    ユーザー名,パスワードを設定しておくこと。
USER=IO.read("./user")
PASS=IO.read("./pass")
ORDER_PASS=IO.read("./order_pass") # 取引パスワード

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