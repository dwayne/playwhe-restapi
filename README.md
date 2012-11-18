# PlayWhe RESTful web API

A Sinatra web application that provides a RESTful web API to a database of past and present PlayWhe results.

**N.B. The database is not provided. Check [here](https://github.com/dwayne/playwhe) or [here](https://bitbucket.org/dwaynecrooks/playwhe).**

## Quick Start

    $ git clone https://dwaynecrooks@bitbucket.org/dwaynecrooks/playwhe-restapi.git

    $ cd playwhe-restapi
    $ rvm use 1.9.3-p194@playwhe-restapi --create
    $ bundle install

    $ echo "PLAYWHE_DATABASE_URL=/path/to/playwhe/database" >> .env
    $ foreman start

In another terminal you can use `curl` to query the service at `http://localhost:5000`.

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
