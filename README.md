PRX.org CMS API
===============
[![License](https://img.shields.io/badge/license-AGPL-blue.svg)](https://www.gnu.org/licenses/agpl-3.0.html)
[![Build Status](https://travis-ci.org/PRX/cms.prx.org.svg?branch=master)](https://travis-ci.org/PRX/cms.prx.org)
[![Code Climate](https://codeclimate.com/github/PRX/cms.prx.org/badges/gpa.svg)](https://codeclimate.com/github/PRX/cms.prx.org)
[![Coverage Status](https://coveralls.io/repos/PRX/cms.prx.org/badge.svg?branch=master)](https://coveralls.io/r/PRX/cms.prx.org?branch=master)
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
These instructions are written assuming Mac OS X install.

### Basics
```
# Homebrew - http://brew.sh/
ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"
brew update

# Git - http://git-scm.com/
brew install git

# Mysql (and run the server somehow) - https://www.mysql.com/
brew install mysql
mysql.server start

# Pow to serve the app - http://pow.cx/
curl get.pow.cx | sh
```

### Ruby & Related Projects
```
# rbenv and ruby-build - https://github.com/sstephenson/rbenv
brew install rbenv ruby-build
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
source ~/.bash_profile

# ruby (.ruby-version default)
rbenv install 2.1.2

# bundler gem - http://bundler.io/
gem install bundler

# powder gem - https://github.com/Rodreegez/powder
gem install powder
```

### Rails Project
Consider forking the repo if you plan to make changes, otherwise you can clone it:
```
# ssh repo syntax (or https `git clone https://github.com/PRX/cms.prx.org.git cms.prx.org`)
git clone git@github.com:PRX/cms.prx.org.git cms.prx.org
cd cms.prx.org

# bundle to install gems dependencies
bundle install

# copy the env-example, fill out the values
cp env-example .env
vi .env
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

### Testing

After bootstrapping the prx.org schema into the test database, just run `bundle exec rake`.  Bingo!

### Development server

The dev server runs through powder - see a [full list of commands](https://github.com/Rodreegez/powder#working-with-pow) over there.

```
powder link
open http://cms.prx.dev
```

License
-------
[AGPL License](https://www.gnu.org/licenses/agpl-3.0.html)


Contributing
------------
Completing a Contributor License Agreement (CLA) is required for PRs to be accepted.
