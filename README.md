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

# Git - http://git-scm.com/
brew install git

# Pow to serve the app - http://pow.cx/
curl get.pow.cx | sh
```

### Ruby & Related Projects
```
brew update

# rbenv and ruby-build - https://github.com/sstephenson/rbenv
brew install rbenv ruby-build
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
source ~/.bash_profile

# ruby (.ruby-version default)
rbenv install

# bundler gem - http://bundler.io/
gem install bundler powder
```

### Rails Project
Consider forking the repo if you plan to make changes, otherwise you can clone it:
```
# ssh repo syntax (or https `git clone https://github.com/PRX/cms.prx.org.git cms.prx.org`)
git clone git@github.com:PRX/cms.prx.org.git cms.prx.org
cd cms.prx.org

# bundle to install gems dependencies
bundle install

# copy the config
cp config/application.yml.example config/application.yml

# copy the env-example, fill out the values
cp env-example .env

# create test database
mysqladmin create prx_test

# run tests
bundle exec rake

# pow set-up
powder link

# see the development status page
open http://cms.prx.dev

# see the api root json doc
open http://cms.prx.dev/api
```

License
-------
[AGPL License](https://www.gnu.org/licenses/agpl-3.0.html)


Contributing
------------
Completing a Contributor License Agreement (CLA) is required for PRs to be accepted.
