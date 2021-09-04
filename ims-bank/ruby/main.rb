require 'sinatra'
require 'sinatra/reloader'
require 'faraday'
require 'faraday_middleware'
require 'monetize'

set :protection, except: :frame_options
set :bind, '0.0.0.0'
set :port, 8080
set :haml, { escape_html: false }

get '/' do
  conn = Faraday.new('https://quietstreamfinancial.github.io') do |f|
    f.response :json
  end

  response = conn.get('/eng-recruiting/transactions.json').body
  users = {}

  response.each do |transaction|
    user_id = transaction['customer_id']
    account_type = transaction['account_type']
    user = users[user_id]
    transaction_amount = Monetize.parse(transaction['transaction_amount']).to_f
    account_amount = transaction[account_type].to_f + transaction_amount

    if user.nil?
      users[user_id] = { account_type => account_amount, 'total' => account_amount, 'name' => transaction['customer_name'] }
    else
      user['name'] ||= transaction['customer_name']
      user[account_type] = account_amount
      user['total'] = (user['total'] + account_amount).round(2)
    end
  end

  haml :table, locals: { data: users, layout: :layout }
end
