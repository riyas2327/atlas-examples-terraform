sudo apt-get -y update
# Dev Stuff
sudo apt-get -y install ruby1.9.3 build-essential libsqlite3-dev
sudo gem install --no-ri --no-rdoc rails
cd /vagrant/project/app; bundle install

# Ops Stuff
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7
sudo cp /vagrant/project/ops/prod/passenger.list /etc/apt/sources.list.d/passenger.list
sudo chown root:root /etc/apt/sources.list.d/passenger.list
sudo chmod 600 /etc/apt/soruces.list.d/passenger.list
sudo apt-get -y update
sudo apt-get -y install apache2 libapache2-mod-passenger
sudo cp /vagrant/project/ops/prod/apache2.conf /etc/apache2/apache2.conf
sudo a2enmod passenger
sudo apache2ctl restart

# Automatically cd into /vagrant
touch /home/vagrant/.profile
grep -q 'cd /vagrant' /home/vagrant/.profile || {
  echo 'cd /vagrant' >> /home/vagrant/.profile
}
