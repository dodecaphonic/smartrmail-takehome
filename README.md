# Fluctuations

Since the challenge wasn't timeboxed, I took a little over 3h (of chunked work) to build this solution. I wanted to focus on getting at something reliable on the API-interaction end, in order to ensure data will be shown on the screen regardless of failures, exceeded quotas and so forth.

The progression of commits tells the story as it unfolded: first, I focused on building a data model that took care of coercing and validating inputs correctly (ExchangeRate). `dry-struct` is a great solution to that problem. Then I focused on parsing data from fixtures extracted from Alpha Vantage's API examples. 

The code from here on uses things that are not typical of Rails projects. `dry-monad`'s Try, Task and Results are great ways to model execution and program flow. I will be happy to expand on that if SmartrMail finds it interesting (or questionable!).

To avoid API call troubles, especially regarding quotas, I thought it would be a good idea to cache values and periodically refresh them. A `Concurrent::TimerTask` queues `RefreshCachedTimeSeriesJob` every minute. `RefreshCachedTimeSeries` then checks if the data is stale and updates it accordingly.

The UI is very simple. It provides a currency switcher, the latest known rate and a graph of the sell price throughout the day. It's built with Stimulus.js and ECharts.

# Running

- First, you must get [an API key from Alpha Vantage](https://www.alphavantage.co/support/#api-key) and set the `ALPHAVANTAGE_API_KEY` environment variable (you can place it in a `.env` file at the project root);

- Install Ruby 2.6.1;

- Run bundler:

        $ bundle install

- With `docker-compose`, start the database:

        $ docker-compose up -d
        
- Setup the database:

        $ bundle exec rails db:setup
        
- Start the server:

        $ bundle exec rails s

- Go to `http://localhost:3000/` on your browser.


## Running Tests

- `bundle exec rspec`
