
# ※「../etc」ディレクトリにuser,passファイルを作成し、
#    ユーザー名,パスワードを設定しておくこと。
USER=IO.read("../etc/user")
PASS=IO.read("../etc/pass")
ORDER_PASS=IO.read("../etc/order_pass") # 取引パスワード

# ログインする
shared_examples_for "login" do
  before(:all) {
    c = SBIClient::Client.new 
    @s = c.fx_session( USER, PASS, ORDER_PASS )
    @rates = @s.list_rates
  }
  after(:all) {
    @s.logout if @s 
  }
  before { @order_id = nil }
  after { @s.cancel_order(@order_id.order_no) if @order_id }
end
