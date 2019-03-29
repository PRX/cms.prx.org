PRX.org CMS API
===============
[![License](https://img.shields.io/badge/license-AGPL-blue.svg)](https://www.gnu.org/licenses/agpl-3.0.html)
[![Build Status](https://snap-ci.com/PRX/cms.prx.org/branch/master/build_image)](https://snap-ci.com/PRX/cms.prx.org/branch/master)
[![Code Climate](https://codeclimate.com/github/PRX/cms.prx.org/badges/gpa.svg)](https://codeclimate.com/github/PRX/cms.prx.org)
[![Coverage Status](https://codecov.io/gh/PRX/cms.prx.org/branch/master/graph/badge.svg)](https://codecov.io/gh/PRX/cms.prx.org)
[![Dependency Status](https://gemnasium.com/PRX/cms.prx.org.svg)](https://gemnasium.com/PRX/cms.prx.org)

Description
-----------
This Rails app provides the CMS API for https://beta.prx.org.

It follows the [standards for PRX services](https://github.com/PRX/meta.prx.org/wiki/Project-Standards#services).

A HAL browser to try out the API is available:
https://cms.prx.org/browser/index.html

Integrations & Dependencies
---------------------------
- mysql - main database
- memcached - caching API responses and JSON representations
- AWS S3 - for private file access
- Lambdas for processing audio (https://github.com/PRX/cms-audio-lambda) and images (https://github.com/PRX/cms-image-lambda)
- (TBD) fixer.prx.org - validate/process media files
- (TBD) meta.prx.org - defines link relations using for HAL resources

Installation
------------
CMS now works in Docker.  You should use Docker.

### Basics
```
# Homebrew - http://brew.sh/
ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"

# Git - http://git-scm.com/
brew install git

# Get the code
git clone git@github.com:PRX/cms.prx.org.git
cd cms.prx.org
```

### Environment
You'll need to `cp env-example .env` and include your credentials.

### Docker Development
Currently on OSX, [Dinghy](https://github.com/codekitchen/dinghy) is probably
the best way to set up your dev environment.  Using VirtualBox is recommended.
Also be sure to install `docker-compose` along with the toolbox.

```
# Build the `web` container, it will also be used for `worker`
docker-compose build

# Start the mysql `db` - if this doesn't work, try a "docker-compose up" first,
# kill that, and then run this command again
docker-compose start db

# ... and run migrations against it
docker-compose run cms setup
docker-compose stop

# Test
docker-compose run cms test

# Guard
docker-compose run cms testsetup
docker-compose run cms guard

# Run the web, worker, and db
docker-compose up
```

### Database bootstrapping

This project uses the [prx.org](https://github.com/PRX/prx.org) database.
So you'll need to get a backup of it to restore to your local development/test databases.

Assuming you have SSH keys for `deploy@cms.prx.org`, you can automatically do this!

```
# Create a new mysqldump (usually you can skip this step)
bundle exec rake db:proddump

# Copy the sql.gz files to your local tmp/dbbootstrap directory
bundle exec rake db:prodcopy

# Now you can restore your local database! (Uses db in your .env file)
bundle exec rake db:bootstrap

# Or to restore your docker-compose database...
docker-compose run cms bootstrap
```

License
-------
[AGPL License](https://www.gnu.org/licenses/agpl-3.0.html)

Contributing
------------
Completing a Contributor License Agreement (CLA) is required for PRs to be accepted.
