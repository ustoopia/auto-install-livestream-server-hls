#!/bin/bash
# Check if script is run with sudo
if [ "$(id -u)" != "0" ]; then
    echo "THIS SCRIPT SHOULD BE RUN BY SUDO. Please try using : sudo bash $0"
    exit 1
fi

# Ask user to input their domain name
read -r -p "Please enter a working domain name that points to your server: " DOMAIN_NAME

# Ask for the user's email address for certbot later on
read -r -p "Please enter your email address (used only for certificates): " EMAIL_ADDRESS

# Temporary store domain name and email address
echo "DOMAIN_NAME=$DOMAIN_NAME" | sudo tee /tmp/user_data > /dev/null
echo "EMAIL_ADDRESS=$EMAIL_ADDRESS" | sudo tee -a /tmp/user_data > /dev/null

# Set DEBIAN_FRONTEND to noninteractive to prevent prompts during apt upgrade
export DEBIAN_FRONTEND=noninteractive

# Set up sudo without password
echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers

# Update repositories and install apps we need for checking the IP's. Also perform general upgrade.
sudo apt-get update -y 
sudo apt-get install curl dnsutils wget unzip git jq -y
sudo apt-get upgrade -y

# Validate the domain name and get its IP address using 1.1.1.1 DNS server
DOMAIN_IP=$(dig +short @"1.1.1.1" "$DOMAIN_NAME")

# Get the user's external IP address
USER_EXTERNAL_IP=$(curl -s https://api64.ipify.org?format=json | jq -r .ip)

# Get the local external IP address
LOCAL_EXTERNAL_IP=$(curl -s ifconfig.me)

# Display the obtained IP addresses
echo "Domain IP: $DOMAIN_IP"
echo "Your external IP: $USER_EXTERNAL_IP"
echo "Local external IP: $LOCAL_EXTERNAL_IP"

# Check if the user's external IP matches the resolved domain IP
if [ "$USER_EXTERNAL_IP" != "$DOMAIN_IP" ]; then
    read -r -p "Your external IP does not match the resolved domain IP. Do you want to continue? (Y/N): " CONTINUE
    if [ "$CONTINUE" != "Y" ]; then
        echo "Aborting script. No changes have been made."
        exit 1
    fi
fi

# Install all the required packages for building the livestream nginx server. And also PHP.
if sudo apt install -y nginx software-properties-common dpkg-dev make gcc automake build-essential python3 python3-pip zlib1g-dev libpcre3 libpcre3-dev libssl-dev libxslt1-dev libxml2-dev libgd-dev libgeoip-dev libgoogle-perftools-dev libperl-dev pkg-config autotools-dev gpac ffmpeg mediainfo mencoder lame libvorbisenc2 libvorbisfile3 libx264-dev libvo-aacenc-dev libmp3lame-dev libopus-dev libnginx-mod-rtmp php-common php-fpm php-gd php-mysql php-imap php-cli php-cgi php-curl php-intl php-pspell php-sqlite3 php-tidy php-xmlrpc php8.1-xml php-memcache php-imagick php-zip php-mbstring php-pear mcrypt imagemagick memcached; then
    echo "Package installation successful."
else
    echo "Error: Could not install packages. Exiting."
    exit 1
fi

# Configure php.ini
sudo sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php/8.1/fpm/php.ini

# Add NGINX Mainline repository
# Disabled since this requires user interaction
# sudo add-apt-repository ppa:ondrej/nginx-mainline
# sudo apt update && sudo apt upgrade -y

# Create some directories
sudo mkdir -p /mnt/livestream/{hls,keys,dash,rec} /var/www/web

# Delete or empty existing nginx.conf
[ -f /etc/nginx/nginx.conf ] && sudo rm /etc/nginx/nginx.conf

# Copy template nginx.conf. Confirm if file copy was succesfull or not
if sudo cp "conf/nginx.conf" "/etc/nginx/nginx.conf"; then
    echo "File copied successfully."
else
    echo "Error: Could not copy the file for some reason. Exiting."
    exit 1
fi

# Copy template vhost to new file and replace domain name
NEW_VHOST_FILE="/etc/nginx/sites-available/$DOMAIN_NAME.vhost"
sudo cp "conf/vhost-template.vhost" "$NEW_VHOST_FILE"
sudo sed -i "s/YOUR.HOSTNAME.COM/$DOMAIN_NAME/g" "$NEW_VHOST_FILE"

# Enable the new vhost
sudo ln -s "$NEW_VHOST_FILE" "/etc/nginx/sites-enabled/"

# Disable the default vhost
sudo rm "/etc/nginx/sites-enabled/default"

# Clone nginx-rtmp-module
if sudo git clone https://github.com/arut/nginx-rtmp-module /usr/src/nginx-rtmp-module; then
    # Copy stat.xsl to web root folder
    sudo cp /usr/src/nginx-rtmp-module/stat.xsl /var/www/web/stat.xsl

    # Copy some more files to web root folder
    sudo cp "webfiles/index.html" "/var/www/web/index.html"
    sudo cp "webfiles/crossdomain.xml" "/var/www/web/crossdomain.xml"
    sudo cp "webfiles/robots.txt" "/var/www/web/robots.txt"
    sudo cp "webfiles/poster.jpg" "/var/www/web/poster.jpg"
else
    echo "Error: Could not clone or copy all the required files. Exiting."
    exit 1
fi

# Change ownership of directories
sudo chown -R www-data: /var/www/web /mnt/livestream

# Install Snap core and Certbot
sudo snap install core; sudo snap refresh core
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot

# Add a line to visudo to restore original sudoers settings on EXIT
echo "$USER ALL=(ALL) ALL" | sudo tee -a /etc/sudoers > /dev/null

# Inform user about completion
echo "Setup completed for $DOMAIN_NAME."
echo "All the package have been successfully installed. Proceeding with certificate request."

# Obtain the certificates.
sudo certbot --nginx -d "$DOMAIN_NAME" --email "$EMAIL_ADDRESS" --agree-tos --noninteractive -m "$EMAIL_ADDRESS"

echo "Completed the certificate request for $DOMAIN_NAME."
echo "Proceeding with dhparam generator. May take a very long time to complete. Don't interrupt it!"

# Generate DH parameters
sudo openssl dhparam -out /etc/nginx/ssl-dhparams.pem 4096

# Check if ssl-dhparams.pem file was created
#if [ -f /etc/nginx/ssl-dhparams.pem ]; then
#    echo "DH parameters generated successfully."
#else
#    echo "Error: DH parameters could not be generated. Exiting."
#    exit 1
#fi

# Add a line to visudo to restore original sudoers settings on EXIT
echo "$USER ALL=(ALL) ALL" | sudo tee -a /etc/sudoers > /dev/null
