# PlayWhe RESTful web API

A Sinatra web application that provides a RESTful web API to a database of past and present PlayWhe results.

**N.B. The database is not provided. Check [here](https://github.com/dwayne/playwhe) or [here](https://bitbucket.org/dwaynecrooks/playwhe).**

## Quick Start

    $ git clone https://dwaynecrooks@bitbucket.org/dwaynecrooks/playwhe-restapi.git
    $ cd playwhe-restapi
    $ echo "PLAYWHE_DATABASE_URL=/path/to/playwhe/database" >> .env
    $ foreman start

In another terminal you can use `curl` to query the service at `http://localhost:5000`.

Get information on all the marks.

    $ curl http://localhost:5000/marks

Maybe, you just want to know the primary spirit associated with a given mark. Then,

    $ curl http://localhost:5000/mark/23

To get the latest 3 results

    $ curl http://localhost:5000/results

To get all the results for a given year, a given month in a given year or for a given day the following queries can be used.

    $ curl http://localhost:5000/results/2012
    $ curl http://localhost:5000/results/2012/10
    $ curl http://localhost:5000/results/2012/10/10
