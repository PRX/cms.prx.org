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

# Start the postgres `db`
docker-compose start db

# ... and run migrations against it
docker-compose run cms setup
docker-compose stop

# Test
docker-compose run app test

# Guard
docker-compose run app guard

# Run the web, worker, and db
docker-compose up
```

### Database bootstrapping
This project uses the [prx.org](https://github.com/PRX/prx.org) database.  So you'll need to get a backup of it to restore to your local development/test databases.  (See the instructions at the end of the prx.org README).

```
# create dev/test databases
mysql -u root -e "CREATE DATABASE cms_prx_org_development;"
mysql -u root -e "CREATE DATABASE cms_prx_org_test;"

# optionally restrict to user (must also be in .env file)
mysql -u root -e "CREATE USER 'cms_prx_user'@'localhost' IDENTIFIED BY 'somepassword'";
mysql -u root -e "GRANT ALL PRIVILEGES ON cms_prx_org_development.* TO 'cms_prx_user'@'localhost';"
mysql -u root -e "GRANT ALL PRIVILEGES ON cms_prx_org_test.* TO 'cms_prx_user'@'localhost';"

# load schemas from backup
gunzip < 20150101_mediajoint_production_structure.gz | mysql -u root cms_prx_org_development
gunzip < 20150101_mediajoint_production_structure.gz | mysql -u root cms_prx_org_test

# load data from backup (NOT needed for the test db)
gunzip < 20150101_mediajoint_production_data.gz | mysql -u root cms_prx_org_development
```

License
-------
[AGPL License](https://www.gnu.org/licenses/agpl-3.0.html)

Contributing
------------
Completing a Contributor License Agreement (CLA) is required for PRs to be accepted.
