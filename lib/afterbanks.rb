# frozen_string_literal: true

# Abstraction and methods to communicate with Afterbanks' API
module Afterbanks
  require 'json'
  require 'httparty'

  # Methods to fetch data from Afterbanks API
  class Fetcher
    def initialize(api_key)
      @api_key = api_key
    end

    # @return [String] json
    def fetch_accounts_json
      HTTParty.post(
        'https://www.afterbanks.com/apiapp/getBanks',
        {
          headers: {
            'Accept' => 'application/json',
            'O-Auth-Token' => @api_key
          },
          format: 'json'
        }
      )
    end

    # @return [Array] of hashes with symbolized keys
    def fetch_accounts
      JSON.parse(fetch_accounts_json, { symbolize_names: true })
    end

    # @return [Hash] with symbolized names
    def fetch_products
      response = fetch_accounts_json
      JSON.parse(response.body, symbolize_names: true)
    end

    # @return [Hash] with symbolized names (?)
    def print_products
      fetch_products.each do |bank|
        next unless bank[:products].is_a?(Array)

        bank[:products].each do |product|
          puts product
        end
      end
    end

    # @return [String] pretty json with all products
    def dummy_fetch_accounts_json
      response = File.read('test_response_accounts.json') # Dummy test
      banks_array = JSON.parse(response, symbolize_names: true) # Dummy test
      products = []
      banks_array.each do |bank|
        next unless bank[:products].is_a?(Array)

        bank[:products].each do |product|
          products.push(product)
        end
      end
      JSON.pretty_generate(products)
    end

    # @param [Array<String>] selected_accounts
    # @param [DateTime] from_datetime
    # @param [DateTime] to_datetime
    # @return [Array<Hash>]
    def fetch_transactions_array(selected_accounts, from_datetime, to_datetime)
      result_json = []
      page_count = 1
      loop do
        response = fetch_transactions_page(page_count, selected_accounts,
                                           from_datetime, to_datetime)
        page_count += 1
        break if JSON.parse(response) == []

        result_json += JSON.parse(response, symbolize_names: true)
      end
      result_json
    end

    def fetch_transactions_json(selected_accounts, from_datetime, to_datetime)
      JSON.pretty_generate(
        fetch_transactions_array(selected_accounts, from_datetime, to_datetime)
      )
    end

    # @param [Array<Hash>]
    def dummy_fetch_transactions_array
      response = File.read('test_response_transactions.json') # Dummy test
      JSON.parse(response, symbolize_names: true) # Dummy
    end

    private

    # @return [HTTParty::Response]
    def fetch_transactions_page(page_number, selected_accounts,
                                from_datetime, to_datetime)
      HTTParty.post(
        'https://www.afterbanks.com/apiapp/getTransactions',
        {
          headers: {
            'Accept' => 'application/json', 'O-Auth-Token' => @api_key
          },
          query: {
            'page' => page_number,
            'advSelectedAccounts' => selected_accounts.join(','),
            'advDateFrom' => from_datetime.strftime('%Y-%m-%d'),
            'advDateTo' => to_datetime.strftime('%Y-%m-%d')
          }, 
          format: 'json'
        }
      )
    end
  end

  # Methods to manage an Afterbanks account synced in a local JSON file
  class SyncedAccount
    attr_reader :account_hash

    # @param [Integer] afterbanks_id
    # @param [Hash] account_hash
    def initialize(afterbanks_id, account_hash)
      @afterbanks_id = afterbanks_id
      @account_hash = account_hash
    end

    # @return [DateTime] last_updated timestamp as DateTime
    def last_updated
      Time.at(@account_hash[:lastupdate_local]).to_datetime
    end

    # @return [Integer]
    def afterbanks_id
      @account_hash[:afterbanks_id]
    end

    # @return [Integer]
    def buckets_id
      @account_hash[:buckets_id]
    end

    # Modify the 'last updated' timestamp of this account
    #
    # @param [DateTime] datetime
    # @return [String] pretty json of the account
    def touch(datetime)
      @account_hash[:lastupdate_local] = datetime.to_time.to_i
      JSON.pretty_generate(@account_hash)
    end
  end

  # Methods to manage Afterbanks accounts synced in a local JSON file
  class SyncedAccountRepository
    require 'json'

    def initialize(file_path)
      @path = file_path
    end

    # @param [Boolean] symbolize_names?
    # @return [Array<Hash>] json parsed as Array<Hash>
    def all_accounts_array(symbolize_names)
      json = File.open(@path).read
      JSON.parse(json, { symbolize_names: symbolize_names })
    end

    # @param [Symbol] id_type (options: :afterbanks, :buckets)
    # @param [Integer] afterbanks_id
    # @return [Hash] account json parsed as hash. unless wrong params, then nil
    def account_hash(id_type, id)
      case id_type
      when :afterbanks
        id_type = :afterbanks_id
      when :buckets
        id_type = :buckets_id
      else
        return nil
      end
      accounts_array = all_accounts_array(true)
      accounts_array.each do |account_hash|
        return account_hash if account_hash[id_type] == id
      end
      {}
    end

    # @param [Symbol] id_type (options: :afterbanks, :buckets)
    # @param [Integer] id
    # @return [SyncedAfterbanksAccount] unless wrong parameters, then nil
    def account(id_type, id)
      account_hash = account_hash(id_type, id)
      return nil if account_hash.nil?

      SyncedAccount.new(id, account_hash)
    end

    # @param [SyncedAfterbanksAccount] account
    def overwrite_account(account)
      accounts_array = all_accounts_array(true)
      accounts_array.each_with_index do |account_hash, index|
        if account_hash[:afterbanks_id] == account.afterbanks_id
          accounts_array[index] = account.account_hash
        end
      end
      File.write(@path, JSON.pretty_generate(accounts_array))
    end
  end
end

# Methods to manipulate a Buckets SQLite DB (budgets)
class Budget
  require 'sqlite3'

  def initialize(path)
    @db = SQLite3::Database.new(path)
  end

  def execute(query)
    @db.execute(query)
  end

  def execute_with_columns(query)
    @db.execute2(query)
  end

  # @param [Integer] account_id
  # @param [Array<Hash>] transactions_array
  def insert_account_transactions_array(account_id, transactions_array)
    transactions_array.each do |transaction|
      insert_account_transaction(
        DateTime.strptime("#{transaction[:date]} 00:00", '%Y-%m-%d %H:%M'),
        account_id,
        transaction[:amount],
        transaction[:description],
        transaction[:md5]
      )
    end
  end

  # @param [DateTime] datetime
  # @param [Integer] account_id
  # @param [Float] amount
  # @param [string] memo
  # @param [string] ext_id
  def insert_account_transaction(
    datetime,
    account_id,
    amount,
    memo = nil,
    ext_id = nil
  )
    query = 'INSERT INTO `account_transaction`(`id`,`posted`,`account_id`,'\
      "`amount`,`memo`,`fi_id`) VALUES (NULL,'#{format_datetime(datetime)}',"\
      "'#{account_id}','#{(amount * 100).to_i}',#{memo ? "'#{memo}'" : 'NULL'},"\
      "#{ext_id ? "'#{ext_id}'" : 'NULL'});"
    execute(query)
  end

  # @param [Afterbanks::SyncedAccountRepository] af_repo
  # @param [Integer] buckets_id
  def update_afterbanks_account(af_repo, buckets_id)
    account = af_repo.account(:buckets, buckets_id)
    af = Afterbanks::Fetcher.new(ENV['AFTERBANKS_API_KEY'])
    now = DateTime.now
    insert_account_transactions_array(
      account.buckets_id,
      af.fetch_transactions_array(
        [account.afterbanks_id],
        account.last_updated,
        now
      )
    )
    account.touch(now)
    af_repo.overwrite_account(account)
  end

  # @param [String] accounts_json_path
  def sync_all_accounts(accounts_json_path)
    af_repo = Afterbanks::SyncedAccountRepository.new(accounts_json_path)
    af_repo.all_accounts_array(true).each do |account|
      update_afterbanks_account(af_repo, account[:buckets_id])
    end
  end

  private

  # @param [DateTime] datetime
  # @return [String]
  def format_datetime(datetime)
    datetime.strftime('%F %T')
  end
end
