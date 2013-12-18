PRX.org Backend
===============
[![Build Status](https://travis-ci.org/PRX/PRX.org-Backend.png?branch=master)](https://travis-ci.org/PRX/PRX.org-Backend) [![Code Climate](https://codeclimate.com/github/PRX/PRX.org-Backend.png)](https://codeclimate.com/github/PRX/PRX.org-Backend) [![Coverage Status](https://coveralls.io/repos/PRX/PRX.org-Backend/badge.png)](https://coveralls.io/r/PRX/PRX.org-Backend) [![Dependency Status](https://gemnasium.com/PRX/PRX.org-Backend.png)](https://gemnasium.com/PRX/PRX.org-Backend)


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
# ssh repo syntax (or https `git clone https://github.com/PRX/PRX.org-Backend.git prx-backend`)
git clone git@github.com:PRX/PRX.org-Backend.git prx-backend
cd prx-backend

# copy the config
cp config/application.yml.example config/application.yml

# bundle to install gems dependencies
bundle install

# pow set-up
powder link

# see the development status page
open http://prx-backend.dev

# see the api root json doc
open http://prx-backend.dev/api
```
