#!/usr/bin/env bash

apt-get update
apt-get install -y curl git gcc libsndfile1-dev ffmpeg imagemagick

# first try git clone
cd /opt
git clone https://Ser1al@github.com/Ser1aL/uawc-final
cd uawc-final

gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
curl -L https://get.rvm.io | bash -s stable
source /usr/local/rvm/scripts/rvm
echo "source /usr/local/rvm/scripts/rvm" >> ~/.bashrc

rvm install ruby-2.2.1
rvm use ruby-2.2.1@uawc-final --default --create

bundle install

cat >/etc/default/locale <<EOL
LC_ALL="en_US.UTF-8"
EOL
source /etc/default/locale

echo 'Starting services'
cd /opt/uawc-final && ./restart_server.sh
echo 'Puma started!'

