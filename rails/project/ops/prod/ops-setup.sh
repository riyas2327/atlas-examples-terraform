sleep 30
sudo mv /tmp/app/* ~
sudo apt-get -y update
# Dev Stuff
sudo apt-get -y install build-essential libsqlite3-dev zlib1g-dev ruby-dev
sudo gem install --no-ri --no-rdoc rails
cd /home/ubuntu/project/app; bundle install

# Ops Stuff
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7
sudo cp /home/ubuntu/project/ops/prod/passenger.list /etc/apt/sources.list.d/passenger.list
sudo chown root:root /apt/sources.list.d/passenger.list
sudo chmod 600 /apt/soruces.list.d/passenger.list
sudo apt-get -y update
sudo apt-get -y install apache2 libapache2-mod-passenger
sudo cp /home/ubuntu/project/ops/prod/project.conf /etc/apache2/sites-enabled/rails.conf
sudo rm /etc/apache2/sites-enabled/000-default.conf /etc/apache2/sites-avaliable/000-default.conf
sudo a2enmod passenger
sudo apache2ctl restart
