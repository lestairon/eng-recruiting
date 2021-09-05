require 'sinatra'
require 'sinatra/reloader'
require 'faraday'
require 'faraday_middleware'
require 'monetize'
Dir[File.join(__dir__, 'services', '*.rb')].each { |file| require file }

set :protection, except: :frame_options
set :bind, '0.0.0.0'
set :port, 8080
set :haml, { escape_html: false }

get '/' do
  conn = Faraday.new('https://quietstreamfinancial.github.io') do |f|
    f.response :json
  end

  response = conn.get('/eng-recruiting/transactions.json').body
  @users = CalculateUsersBalanceService.execute(response)

  haml :table, locals: { layout: :layout }
end
