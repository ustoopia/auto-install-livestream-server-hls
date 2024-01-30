#!/bin/bash
# ################################################################
# Hi, my name is auto-install-livestream-server-hls. I live at   #
# https://github.com/ustoopia/auto-install-livestream-server-hls #
# I'm going to build you a fully configured live-stream server.  #
# Lucky you! To really get me going: sudo bash auto-installer.sh #
# ################################################################

# I need to make sure you used to sudo to get me going
if [ "$(id -u)" != "0" ]; then
    echo "THIS SCRIPT SHOULD BE RUN AS SUDO. Please try using: sudo bash $0"
    exit 1
fi

# Asking the user, very politely, to enter their domain name for the server
read -r -p "Please enter a working domain name that points to your server: " DOMAIN_NAME

# Asking the user to enter their email address, also in a polite manner
read -r -p "Please enter your email address. Used only for the certificate request: " EMAIL_ADDRESS

# Temporary store the entered domain name and email address so we can use it later on
echo "DOMAIN_NAME=$DOMAIN_NAME" | sudo tee /tmp/user_data > /dev/null
echo "EMAIL_ADDRESS=$EMAIL_ADDRESS" | sudo tee -a /tmp/user_data > /dev/null

# I want to run the entire scipt myself without bothering my user for confirmation prompts
export DEBIAN_FRONTEND=noninteractive

# Temporary allow me to use sudo without having to ask my user to enter their password each time.
echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers

# Updating repositories and installing apps I'm needing for the next steps. 
sudo apt-get update -y 
sudo apt-get install curl dnsutils wget unzip git jq -y

# Validating the entered domain name and checking its IP address using the 1.1.1.1 DNS server
DOMAIN_IP=$(dig +short @"1.1.1.1" "$DOMAIN_NAME")

# Looking up what the internet facing IP address is of my current location
USER_EXTERNAL_IP=$(curl -s https://api64.ipify.org?format=json | jq -r .ip)

# I also want to know our current local IP address, so I can compare the three IPs.
LOCAL_EXTERNAL_IP=$(curl -s ifconfig.me)

# A list showing the results of the IPs that I collected.
echo "Domain IP: $DOMAIN_IP"
echo "Your external IP: $USER_EXTERNAL_IP"
echo "Local external IP: $LOCAL_EXTERNAL_IP"

# Check if the user's external IP matches to the resolved domain name IP address, because they really should match!
if [ "$USER_EXTERNAL_IP" != "$DOMAIN_IP" ]; then
    read -r -p "Your external IP does not match the resolved domain name IP address. I actually prefer that it does. Not certain if we should continue. Do you want to continue? (Y/N): " CONTINUE
    if [ "$CONTINUE" != "Y" ]; then
        echo "Aborting script. This is probably for the best. Make sure the domain name points to your server first. No changes have been made."
        exit 1
    fi
fi

# Install all the required packages that are the building blocks for the live-stream server. Also installing PHP allowing you to use php webpages
if sudo apt install -y nginx software-properties-common dpkg-dev make gcc automake build-essential python3 python3-pip zlib1g-dev libpcre3 libpcre3-dev libssl-dev libxslt1-dev libxml2-dev libgd-dev libgeoip-dev libgoogle-perftools-dev libperl-dev pkg-config autotools-dev gpac ffmpeg mediainfo mencoder lame libvorbisenc2 libvorbisfile3 libx264-dev libvo-aacenc-dev libmp3lame-dev libopus-dev libnginx-mod-rtmp mcrypt imagemagick memcached php-common php-fpm php-gd php-cli php-cgi php-curl php-imagick php-zip php-mbstring php-pear; then
    echo "Package installation successful."
else
    echo "Error: Could not install packages. Exiting."
    exit 1
fi

# This adds the NGINX Mainline repository to upgrade Nginx to a more recent version.
# We won't be doing that right now because it requires the user's input. Maybe some other time.
# sudo add-apt-repository ppa:ondrej/nginx-mainline
# sudo apt update && sudo apt upgrade -y

# Configure php.ini so it will play nice with NginX
sudo sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php/8.1/fpm/php.ini

# Create folders to store our web page and folders to store the live-stream temp files
sudo mkdir -p /mnt/livestream/{hls,keys,dash,rec} /var/www/web

# Delete or empty the existing default ginx.conf file
[ -f /etc/nginx/nginx.conf ] && sudo rm /etc/nginx/nginx.conf

# Copy the template nginx.conf to where it needs to be. Confirm if file copy was succesfull or not
if sudo cp "conf/nginx.conf" "/etc/nginx/nginx.conf"; then
    echo "File copied successfully."
else
    echo "Error: Could not copy the file for some weird f*cked up reason. Sorry! Exiting."
    exit 1
fi

# Using the entered domain name to create a new vhost file, adding domain name to it, and storing it where it needs to go.
NEW_VHOST_FILE="/etc/nginx/sites-available/$DOMAIN_NAME.vhost"
sudo cp "conf/vhost-template.vhost" "$NEW_VHOST_FILE"
sudo sed -i "s/YOUR.HOSTNAME.COM/$DOMAIN_NAME/g" "$NEW_VHOST_FILE"

# Enabling the new vhost by creating a link to it.
sudo ln -s "$NEW_VHOST_FILE" "/etc/nginx/sites-enabled/"

# Removing the link to the default vhost since we don't need it anymore.
sudo rm "/etc/nginx/sites-enabled/default"

# Cloning the official nginx-rtmp-module cause we need an important file from it 
if sudo git clone https://github.com/arut/nginx-rtmp-module /usr/src/nginx-rtmp-module; then
    # Copy the file stat.xsl to the web root folder
    sudo cp /usr/src/nginx-rtmp-module/stat.xsl /var/www/web/stat.xsl

    # Copy these files to the web root folder as well
    sudo cp -r "webfiles/" "/var/www/web"
else
    echo "Error: Could not copy all the required files. This really sucks!! Exiting."
    exit 1
fi

# Change ownership of the new folders so Nginx can write to them
sudo chown -R www-data: /var/www/web /mnt/livestream

# Install Snap core first so we can then install Certbot
sudo snap install core; sudo snap refresh core
sudo snap install --classic certbot
# Create a link to certbot so we can use it later on
sudo ln -s /snap/bin/certbot /usr/bin/certbot

# Time to have a little chat with the user to let hum know what I've been doing.
echo "Setup is pretty much completed for $DOMAIN_NAME."
echo "All the package have been successfully installed. The very last step is to request a certificate."
echo "I should be able to do this on my own. But I would appreciate it if you kept an eye on me, to see if everything went well."

# Obtain the certificates.
sudo certbot --nginx -d "$DOMAIN_NAME" --email "$EMAIL_ADDRESS" --agree-tos --noninteractive -m "$EMAIL_ADDRESS"

# I feel that I should have another chat with our user. Communication is very important in a relationship!
echo "Finished the certificate request for $DOMAIN_NAME."
echo "Proceeding to generate the dhparam file. I'm doing the best I can, but this will take a long time to complete. Please don't interrupt me while I'm doing all the hard work!"

# Generate DH parameters and create the file in the nginx folder
sudo openssl dhparam -out /etc/nginx/ssl-dhparams.pem 4096

# Quick check if ssl-dhparams.pem file was created succesfully
if [ -f /etc/nginx/ssl-dhparams.pem ]; then
    echo "DH parameters file generated successfully. Aren't you proud of me?"
else
    echo "Error: DH parameters could not be generated. I'm so sorry about this! Exiting."
    exit 1
fi

# Add a line to visudo to restore the original settings in case the script in finished or on EXIT
echo "$USER ALL=(ALL) ALL" | sudo tee -a /etc/sudoers > /dev/null

echo "It seems everything was successful! This means I've completed all my tasks!"
echo "Make sure that you take a look at the included docs to familiarize yourself with the server."
echo "It has been a real pleasure. I am outta here! Goodbye."
