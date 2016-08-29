sudo apt-get -y update

# install consul
echo Installing dependencies...
sudo apt-get install -y unzip
sudo apt-get install -y curl
echo Fetching Consul...
cd /tmp/
wget https://releases.hashicorp.com/consul/0.6.4/consul_0.6.4_linux_amd64.zip -O consul.zip
echo Installing Consul...
unzip consul.zip
sudo chmod +x consul
sudo mv consul /usr/bin/consul
sudo mkdir -m 777 /etc/consul.d
sudo chmod a+w /var/log
sudo chmod a+w /etc/init/
