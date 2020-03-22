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

budget = Budget.new(File.dirname(__FILE__) + '/db/budget.buckets')
budget.sync_all_accounts(File.dirname(__FILE__) + '/db/accounts.json')
