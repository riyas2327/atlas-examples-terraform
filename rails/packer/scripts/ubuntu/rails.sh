#!/bin/bash

set -e

# Update package cache. May be out of step with base ami
apt-get update

# Ruby 2.2.3
source /etc/profile.d/rvm.sh
rvm install ruby 2.2.3
echo 'gem: --no-rdoc --no-ri' > /etc/gemrc
gem install bundler

# Apache2 + Passenger
apt-get install -y apache2 build-essential libgmp3-dev nodejs
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
apt-get install -y apt-transport-https ca-certificates
sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main > /etc/apt/sources.list.d/passenger.list'
apt-get update
# Install Passenger + Apache module
apt-get install -y libapache2-mod-passenger
a2enmod passenger

cp $CONFIGDIR/apache2/rails.conf /etc/apache2/sites-available/rails.conf

a2dissite 000-default
a2ensite rails

cd /application
bundle install
