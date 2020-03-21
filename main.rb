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

budget = Budget.new('db/test.buckets')
af_repo = Afterbanks::SyncedAccountRepository.new('db/accounts.json')
budget.update_afterbanks_account(af_repo, 2)

# af_repo.all_accounts_array.each do |account|
#   budget.update_account[af_repo, account[:buckets_id]]
# end

# p af.fetch_transactions_json(
#   ['105513'],
#   DateTime.strptime('03/12/2019 23:33', '%d/%m/%Y %H:%M'),
#   DateTime.strptime('03/12/2020 23:33', '%d/%m/%Y %H:%M')
# )

# af_repo = Afterbanks::SyncedAccountRepository.new('accounts.json')
# p af_repo.account(102_068).account_hash

# accounts = budget.execute('select * from account')
# test_date = DateTime.strptime('11/03/2020 23:33', '%d/%m/%Y %H:%M')
# af = AfterbanksFetcher.new(ENV['AFTERBANKS_API_KEY'])
# af.touch_local_accounts_json('db/accounts.json', 105_513, test_date)


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
