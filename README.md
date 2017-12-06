# About

A [Roda](http://roda.jeremyevans.net/) web application that provides a RESTful API for PlayWhe results.

**N.B.** *A database of PlayWhe results is provided (see the `data` directory) for testing purposes.*

## Prerequisites

1. [Ruby 2.4.2](https://ruby-doc.org/core-2.4.2/)
2. [rbenv](https://github.com/sstephenson/rbenv)

## Quick Start

```sh
$ git clone git@github.com:dwayne/playwhe-restapi.git
$ cd playwhe-restapi
$ bundle install
$ bundle exec rake thin:start
```

In another terminal you can use `curl` to query the service at `http://127.0.0.1:5000`.

When you're ready to stop the server, execute

```sh
$ bundle exec rake thin:stop
```

## Usage

Get information on all the marks.

```sh
$ curl http://127.0.0.1:5000/marks
```

Maybe, you just want to know the primary spirit associated with a given mark. Then,

```sh
$ curl http://127.0.0.1:5000/marks/23
```

To get the latest results,

```sh
$ curl http://127.0.0.1:5000/results
```

You'd notice that only the latest 10 results are returned. If you want to see more, then you can change the `limit` query parameter. For example, the following request will get 100 results.

```sh
$ curl http://127.0.0.1:5000/results?limit=100
```

Get the results for a given year.

```sh
$ curl http://127.0.0.1:5000/results?year=2012
```

Get the results for a given month in a given year.

```sh
$ curl http://127.0.0.1:5000/results?year=2012&month=10
```

Get all the results for a given day in a given month in a given year.

```sh
$ curl http://127.0.0.1:5000/results?year=2012&month=10&day=10
```

The default sort order is in descending order of the draw number. If you want to sort the results in ascending order of the draw number, then issue the following request.

```sh
$ curl http://127.0.0.1:5000/results?order=asc
```

You can also query the results based on the draw number, the period or the number.

```sh
$ curl http://127.0.0.1:5000/results?draw=1
$ curl http://127.0.0.1:5000/results?period=AM
$ curl http://127.0.0.1:5000/results?number=23
```

Finally, feel free to mix and match parameters. The request below returns the 2nd page of 5 results for which the number 3 played in the evening for the year 2008.

```sh
$ curl http://127.0.0.1:5000/results?page=2&limit=5&number=3&period=pm&year=2008
```

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

**N.B.** *See [playwhe-tweet](https://dev.twitter.com/apps/3841469/show) for the Twitter credentials.*

### Step 3

Add a cron job.

    $ export EDITOR=nano; crontab -e

And then, edit it to have `playwhe-tweet.sh` run every 5 minutes.

    */5 * * * * /path/to/playwhe-tweet.sh > /dev/null 2>> /path/to/playwhe-tweet.log

### Step 4

There is no step 4. The script is now setup to automatically tweet the latest Play Whe results.

## Configuring `playwhe-facebook-post.sh`

### Step 1

Copy `playwhe-facebook-post-example.sh` to `playwhe-facebook-post.sh` and make it executable by the user.

    $ cp playwhe-facebook-post-example.sh playwhe-facebook-post.sh
    $ chmod u+x playwhe-facebook-post.sh

### Step 2

Open `playwhe-facebook-post.sh` and setup the following environment variables:

- `PLAYWHE_DATABASE_URL` the path to the Play Whe database
- `PLAYWHE_FACEBOOK_POSTRC_PATH` the path to `.playwhe-facebook-postrc`
- `FACEBOOK_PAGE_ACCESS_TOKEN`

### Step 3

Add a cron job.

    $ export EDITOR=nano; crontab -e

And then, edit it to have `playwhe-facebook-post.sh` run every 5 minutes.

    */5 * * * * /path/to/playwhe-facebook-post.sh > /dev/null 2>> /path/to/playwhe-facebook-post.log

### Step 4

There is no step 4. The script is now setup to automatically post the latest Play Whe results.

## Credits

Developed by [Dwayne Crooks](http://www.dwaynecrooks.com/).
