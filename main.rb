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
account = Afterbanks::SyncedAccountRepository
          .new('db/accounts.json')
          .account('105513'.to_i)
af = Afterbanks::Fetcher.new(ENV['AFTERBANKS_API_KEY'])
af.fetch_transactions_array(
  ['105513'],
  DateTime.strptime('2020-01-01 00:00', '%Y-%m-%d %H:%M'),
  DateTime.strptime('2020-04-01 00:00', '%Y-%m-%d %H:%M')
).each do |transaction|
  budget.insert_account_transaction(
    DateTime.strptime("#{transaction[:date]} 00:00", '%Y-%m-%d %H:%M'),
    account.account_hash[:buckets_id],
    transaction[:amount],
    transaction[:description],
    transaction[:md5]
  )
end

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
