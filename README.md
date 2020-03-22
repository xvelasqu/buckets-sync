# buckets-sync
Tool for automatic accounts & transactions sync with the [Buckets](https://www.budgetwithbuckets.com/) budgeting software. Requires Ruby `>=2.6` and Bundler `>=2.1`. 

Works with:
- [Afterbanks](https://www.afterbanks.com)

## Usage
1. Create a file `db/accounts.json` according to the example
2. Create a symbolic link `db/budget.buckets` pointing to your budget file
3. Run `bundle install` once
4. Make sure that the Buckets application is not open, and run `ruby main.rb`
