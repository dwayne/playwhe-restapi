#!/bin/bash --login

# Add me to crontab
# export EDITOR=nano; crontab -e
# */5 * * * * /path/to/playwhe-tweet.sh > /dev/null 2>> /path/to/playwhe-tweet.log

# the path to the Play Whe database
export PLAYWHE_DATABASE_URL=

# the path to .playwhe-tweetrc
export PLAYWHE_TWEETRC_PATH=

# Twitter credentials, see https://dev.twitter.com/apps/3841469/show
export TWITTER_CONSUMER_KEY=
export TWITTER_CONSUMER_SECRET=
export TWITTER_OAUTH_TOKEN=
export TWITTER_OAUTH_SECRET=

cd /path/to/directory/containing/playwhe-tweet.rb
bundle exec ruby playwhe-tweet.rb
