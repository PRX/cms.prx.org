PRX.org CMS API
===============
[![Build Status](https://travis-ci.org/PRX/cms.prx.org.svg?branch=master)](https://travis-ci.org/PRX/cms.prx.org)
[![Code Climate](https://codeclimate.com/github/PRX/cms.prx.org/badges/gpa.svg)](https://codeclimate.com/github/PRX/cms.prx.org)
[![Coverage Status](https://coveralls.io/repos/PRX/cms.prx.org/badge.svg?branch=master)](https://coveralls.io/r/PRX/cms.prx.org?branch=master)
[![Dependency Status](https://gemnasium.com/PRX/cms.prx.org.svg)](https://gemnasium.com/PRX/cms.prx.org)

Install
-------
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
