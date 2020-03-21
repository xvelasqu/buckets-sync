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
budget.sync_all_accounts('db/accounts.json')
