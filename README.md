# PlayWhe RESTful web API

A Sinatra web application that provides a RESTful web API to a database of past and present PlayWhe results.

A database of past PlayWhe results is provided (see the `data` directory) for testing purposes.

## Prerequisites

1. Ruby 1.9.3
2. [rbenv](https://github.com/sstephenson/rbenv).

## Quick Start

    $ git clone git@bitbucket.org:dwaynecrooks/playwhe-restapi.git

    $ cd playwhe-restapi
    $ bundle install

    $ rake thin:start

In another terminal you can use `curl` to query the service at `http://localhost:5000`.

When you are ready to stop the server, execute

    $ rake thin:stop

## Usage

Get information on all the marks.

    $ curl http://localhost:5000/marks

Maybe, you just want to know the primary spirit associated with a given mark. Then,

    $ curl http://localhost:5000/mark/23

To get the latest results,

    $ curl http://localhost:5000/results

You'd notice that only the latest 10 results were returned. If you want to see more, then you can use the `limit` and `offset` query parameters. For example, the following request will get the next 100 results.

    $ curl http://localhost:5000/results?limit=100&offset=10

Get all the results for a given year.

    $ curl http://localhost:5000/results?year=2012&limit=365

Get all the results for a given month in a given year.

    $ curl http://localhost:5000/results?year=2012&month=10&limit=31

Get all the results for a given day in a given month in a given year.

    $ curl http://localhost:5000/results?year=2012&month=10&day=10&limit=3

The default sort order is in descending order of the draw number. If you want to sort the results in ascending order of the draw number, then issue the following request.

    $ curl http://localhost:5000/results?order=asc

You can also query the results based on the draw number, the period or the number.

    $ curl http://localhost:5000/results?draw=1
    $ curl http://localhost:5000/results?period=2
    $ curl http://localhost:5000/results?number=23

Finally, feel free to mix and match paramters. The request below returns the 2nd set of 5 results for which the number 13 played after lunch for the year 2008.

    $ curl http://localhost:5000/results?limit=5&offset=5&year=2008&period=2&number=13

## Configuring `playwhe-tweet.sh`

### Step 1

Copy `playwhe-tweet-example.sh` to `playwhe-tweet.sh` and make it executable by the user.

    $ cp playwhe-tweet-example.sh playwhe-tweet.sh
    $ chmod u+x playwhe-tweet.sh

### Step 2

Open `playwhe-tweet.sh` and setup the following environment variables:

- `PLAYWHE_DATABASE_URL` the path to the Play Whe database
- `PLAYWHE_TWEETRC_PATH` the path to `.playwhe-tweetrc`
- `TWITTER_CONSUMER_KEY`
- `TWITTER_CONSUMER_SECRET`
- `TWITTER_OAUTH_TOKEN`
- `TWITTER_OAUTH_SECRET`

**N.B.** See [playwhe-tweet](https://dev.twitter.com/apps/3841469/show) for the Twitter credentials.

### Step 3

Add a cron job.

    $ export EDITOR=nano; crontab -e

And then, edit it to have `playwhe-tweet.sh` run every 5 minutes.

    */5 * * * * /path/to/playwhe-tweet.sh > /dev/null 2>> /path/to/playwhe-tweet.log

### Step 4

There is no step 4. The script is now setup to automatically tweet the latest Play Whe results.

## TODO

- App monitoring on WebFaction (check out [god](http://godrb.com/))
- Authentication
- Throttle requests

## Credits

Developed by [Dwayne R. Crooks](http://dwaynecrooks.com/).
