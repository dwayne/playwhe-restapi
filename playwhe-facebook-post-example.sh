#!/bin/bash --login

# Add me to crontab
# export EDITOR=nano; crontab -e
# */5 * * * * /path/to/playwhe-facebook-post.sh > /dev/null 2>> /path/to/playwhe-facebook-post.log

# the path to the Play Whe database
export PLAYWHE_DATABASE_URL=

# the path to .playwhe-facebook-postrc
export PLAYWHE_FACEBOOK_POSTRC_PATH=

# Facebook page access token, see https://developers.facebook.com/docs/facebook-login/access-tokens#pagetokens
export FACEBOOK_PAGE_ACCESS_TOKEN=

cd /path/to/directory/containing/playwhe-facebook-post.rb
bundle exec ruby playwhe-facebook-post.rb
