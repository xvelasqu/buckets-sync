# buckets-sync
Tool for automatic transactions sync with the [Buckets](https://www.budgetwithbuckets.com/) budgeting software. Requires Ruby `>=2.6`, Bundler `>=2.1`, SQLite `>3` & SQLite 3 development files (`libsqlite3-dev`). 

Works with:
- [Afterbanks](https://www.afterbanks.com)

## Usage
1. Create a file `db/accounts.json` according to the example
2. Create a symbolic link `db/budget.buckets` pointing to your budget file
3. Run `bundle install` once
4. Make sure that the Buckets application is not open, and run `ruby main.rb`
