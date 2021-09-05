class User
  attr_reader :id
  attr_accessor :accounts, :name

  def initialize(name:, accounts: [], id:)
    @name = name
    @accounts = accounts
    @id = id
  end

  def total
    @total ||= (total_checking + total_savings).round(2)
  end

  def total_checking
    @total_checking ||= accounts.sum { |saving| saving.account_type == 'checking' ? saving.amount : 0 }.round(2)
  end

  def total_savings
    @total_savings ||= accounts.sum { |saving| saving.account_type == 'savings' ? saving.amount : 0 }.round(2)
  end
end
