#! /bin/bash
cwd=`pwd`

chmod +x *.sh

read -p "Would you like to also install Airplay support (Y/n)? " shairport

case $shairport in
        [nN] ) 
        	echo "shairport-sync (Airplay) will NOT be installed."
        ;;
        * )
        	echo "shairport-sync (Airplay) WILL be installed."
        ;;
esac

sudo apt-get update

sudo apt-get install swig3.0 python-pyaudio python3-pyaudio sox pulseaudio -y
sudo apt-get install libatlas-base-dev -y
sudo apt-get install python-pygame -y

sudo apt-get install wget python-dev swig libasound2-dev memcached python-pip python-alsaaudio vlc -y
wget --output-document vlc.py "http://git.videolan.org/?p=vlc/bindings/python.git;a=blob_plain;f=generated/vlc.py;hb=HEAD"
sudo pip install -r requirements.txt

case $shairport in
        [nN] ) ;;
        * )
                echo "--building and installing shairport-sync--"
                cd ..
                sudo apt-get install git autoconf libdaemon-dev libasound2-dev libpopt-dev libconfig-dev avahi-daemon libavahi-client-dev libssl-dev libsoxr-dev -y
                git clone https://github.com/mikebrady/shairport-sync.git
                cd shairport-sync
                autoreconf -i -f
                ./configure --with-alsa --with-avahi --with-ssl=openssl --with-soxr --with-metadata --with-pipe --with-systemd
                make
                getent group shairport-sync &>/dev/null || sudo groupadd -r shairport-sync >/dev/null
                getent passwd shairport-sync &> /dev/null || sudo useradd -r -M -g shairport-sync -s /usr/bin/nologin -G audio shairport-sync >/dev/null
                sudo make install
                sudo systemctl enable shairport-sync
                cd $cwd
                rm -r ../shairport-sync
        ;;
esac

sudo cp initd_alexa.sh /etc/init.d/AlexaPi
sudo update-rc.d AlexaPi defaults
sudo touch /var/log/alexa.log

echo "--Creating creds.py--"
echo "Enter your Device Type ID:"
read productid
echo ProductID = \"$productid\" > creds.py

echo "Enter your Security Profile Description:"
read spd
echo Security_Profile_Description = \"$spd\" >> creds.py

echo "Enter your Security Profile ID:"
read spid
echo Security_Profile_ID = \"$spid\" >> creds.py

echo "Enter your Client ID:"
read cid
echo Client_ID = \"$cid\" >> creds.py

echo "Enter your Client Secret:"
read secret
echo Client_Secret = \"$secret\" >> creds.py

python ./auth_web.py 
