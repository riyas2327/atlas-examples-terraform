# Copyright 2015 Google Inc. All Rights Reserved.
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# exit on exception
set -e

# configure hyperspace (previously downloaded with scripts/base.sh)
cd /home/hyperspace/hyperspace
sudo -u hyperspace sed -i "s|localhost|hyperspace-be|" etc/nginx.conf
sudo -u hyperspace sed -i '3d' etc/nginx.conf
sudo -u hyperspace sed -i '28,33d' etc/nginx.conf

# install nginx
sudo apt-get install -y nginx
sudo rm /etc/nginx/sites-enabled/default
sudo cp /home/hyperspace/hyperspace/etc/nginx.conf /etc/nginx/sites-enabled/default
sudo service nginx restart
