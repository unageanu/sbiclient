
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
