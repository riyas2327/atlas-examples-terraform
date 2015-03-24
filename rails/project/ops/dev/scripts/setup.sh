sudo apt-get -y update
# Dev Stuff
sudo apt-get -y install ruby1.9.3 build-essential libsqlite3-dev
sudo gem install --no-ri --no-rdoc rubygems-update
sudo update_rubygems
sudo gem install --no-ri --no-rdoc rails
cd /vagrant/project/app; bundle install

# Automatically cd into /vagrant
touch /home/vagrant/.profile
grep -q 'cd /vagrant' /home/vagrant/.profile || {
  echo 'cd /vagrant' >> /home/vagrant/.profile
}
