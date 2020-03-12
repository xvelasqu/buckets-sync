# frozen_string_literal: true

require 'rubygems'
require 'dotenv'

Dir[File.dirname(__FILE__) + '/lib/*.rb']
  .entries
  .sort
  .each { |f| require f }
Dir[File.join('.', 'lib/**/*.rb')]
  .entries
  .sort
  .each { |f| require f }

#####
# Main
#####

# Init
Dotenv.load

af_repo = Afterbanks::SyncedAccountRepository.new('accounts.json')
p af_repo.account(102_068).account_hash

# budget = Budget.new('test.buckets')
# accounts = budget.execute('select * from account')
# test_date = DateTime.strptime('11/03/2020 23:33', '%d/%m/%Y %H:%M')
# budget.insert_account_transaction(test_date, accounts[0][0], 230_11, 'lol')
# af = AfterbanksFetcher.new(ENV['AFTERBANKS_API_KEY'])
# af.touch_local_accounts_json('accounts.json', 105_513, test_date)


# accounts.each do |row|∫
#   p row
# end
# p '---'
# account_transactions = budget.execute_with_columns(
#   'select * from account_transaction'
# )
# account_transactions.each do |row|
#   p row
# end
