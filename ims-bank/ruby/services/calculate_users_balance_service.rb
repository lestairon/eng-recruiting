require './user'

class CalculateUsersBalanceService < ApplicationService
  attr_reader :transactions
  attr_accessor :users

  def initialize(transactions = [])
    @transactions = transactions
    @users = []
  end

  def execute
    transactions.each do |transaction|
      transaction_data = get_transaction_data(transaction)
      user = find_user(transaction_data.user_id)

      user ? modify_existing_user(user, transaction_data) : create_user(transaction_data)
    end

    users
  end

  private

  def parse_transaction_amount(amount)
    Monetize.parse(amount).to_f
  end

  def create_account(transaction)
    OpenStruct.new(amount: transaction.amount, account_type: transaction.account_type, account_number: transaction.account_number)
  end

  def create_user(transaction)
    account = create_account(transaction)

    users << User.new(accounts: [account], name: transaction.user_name, id: transaction.user_id)
  end

  def modify_existing_user(user, transaction)
    user.name ||= transaction.user_name
    account = find_user_account(user, transaction.account_number)

    account ? modify_user_account(account, transaction) : add_account_to_user(user, transaction)
  end

  def modify_user_account(account, transaction)
    account.account_type ||= transaction.account_type
    account.amount += transaction.amount
  end

  def add_account_to_user(user, transaction)
    user.accounts << create_account(transaction)
  end

  def get_transaction_data(transaction)
    account_number = transaction['account_number']
    user_id = transaction['customer_id']
    user_name = transaction['customer_name']
    account_type = transaction['account_type']
    amount = transaction['transaction_amount']
    amount = parse_transaction_amount(amount)

    OpenStruct.new(amount: amount, account_number: account_number, user_id: user_id, user_name: user_name, account_type: account_type)
  end

  def find_user(id)
    users.find { |user| user.id == id }
  end

  def find_user_account(user, account_id)
    user.accounts.find { |saving| saving.account_number == account_id }
  end
end
